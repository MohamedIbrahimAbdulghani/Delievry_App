<?php

namespace App\Modules\Payments\Services;

use App\Modules\Orders\Models\Order;
use App\Modules\Payments\Http\Resources\PaymentResource;
use App\Modules\Payments\Models\Payment;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

use App\Models\User;
use App\Modules\Cart\Repositories\CartRepository;
use App\Modules\Restaurants\Models\Restaurant;
use Stripe\StripeClient;

class PaymentService
{
    public function __construct(
        protected CartRepository $carts,
    ) {}

    /**
     * @return array{client_secret: string, stripe_payment_intent_id: string, amount: float}
     */
    public function createCheckoutIntent(User $user, string $deliveryAddress, ?string $notes): array
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $this->carts->loadWithItems($cart);

        if ($cart->items->isEmpty()) {
            throw ValidationException::withMessages([
                'cart' => [__('Cart is empty.')],
            ]);
        }

        // Group cart items by restaurant_id
        $itemsByRestaurant = [];
        foreach ($cart->items as $line) {
            $product = $line->product;
            if (! $product || ! $product->is_available) {
                throw ValidationException::withMessages([
                    'cart' => [__('One or more products are no longer available.')],
                ]);
            }
            $rid = (int) $product->restaurant_id;
            $itemsByRestaurant[$rid][] = $line;
        }

        $totalAmount = 0.0;

        foreach ($itemsByRestaurant as $rid => $lines) {
            $restaurant = Restaurant::query()->findOrFail($rid);
            if (! $restaurant->is_active) {
                throw ValidationException::withMessages([
                    'cart' => [__('Restaurant ":name" is not accepting orders.', ['name' => $restaurant->name])],
                ]);
            }

            $subtotal = 0.0;
            foreach ($lines as $line) {
                $subtotal += (float) $line->product->price * (int) $line->quantity;
            }
            $deliveryFee = (float) $restaurant->delivery_fee;
            $totalAmount += $subtotal + $deliveryFee;
        }

        $totalAmount = round($totalAmount, 2);

        $stripe = new StripeClient(config('services.stripe.secret'));

        $intent = $stripe->paymentIntents->create([
            'amount' => (int) ($totalAmount * 100), // Stripe expects amounts in cents
            'currency' => 'usd',
            'metadata' => [
                'user_id' => $user->id,
                'cart_id' => $cart->id,
                'delivery_address' => $deliveryAddress,
                'notes' => $notes ?? '',
            ],
            'automatic_payment_methods' => [
                'enabled' => true,
            ],
        ]);

        return [
            'client_secret' => $intent->client_secret,
            'stripe_payment_intent_id' => $intent->id,
            'amount' => $totalAmount,
        ];
    }

    /**
     * @return array{payment: PaymentResource, client_secret: null, message: string}
     */
    public function createIntent(Order $order, string $paymentMethod): array
    {
        $existing = $order->payments()
            ->where('method', $paymentMethod)
            ->where('status', Payment::STATUS_PENDING)
            ->orderByDesc('id')
            ->first();

        if ($existing) {
            return [
                'payment' => new PaymentResource($existing),
                'client_secret' => null,
                'message' => $paymentMethod === Payment::METHOD_COD
                    ? __('Cash on delivery payment is pending.')
                    : __('Use your payment provider to complete this order.'),
            ];
        }

        if ($paymentMethod === Payment::METHOD_COD) {
            $payment = Payment::query()->create([
                'order_id' => $order->id,
                'method' => Payment::METHOD_COD,
                'status' => Payment::STATUS_PENDING,
                'amount' => $order->total,
                'provider' => null,
                'provider_ref' => null,
                'meta' => ['cod' => true],
            ]);

            return [
                'payment' => new PaymentResource($payment),
                'client_secret' => null,
                'message' => __('Cash on delivery selected.'),
            ];
        }

        if ($paymentMethod === Payment::METHOD_CARD) {
            $payment = Payment::query()->create([
                'order_id' => $order->id,
                'method' => Payment::METHOD_CARD,
                'status' => Payment::STATUS_PENDING,
                'amount' => $order->total,
                'provider' => 'stub',
                'provider_ref' => 'stub_'.Str::uuid()->toString(),
                'meta' => [
                    'client_secret' => null,
                    'note' => __('Replace with real gateway integration.'),
                ],
            ]);

            return [
                'payment' => new PaymentResource($payment),
                'client_secret' => null,
                'message' => __('Payment intent placeholder created.'),
            ];
        }

        throw ValidationException::withMessages([
            'payment_method' => [__('Unsupported payment method.')],
        ]);
    }

    public function handleWebhookEvent($event): array
    {
        if ($event->type === 'payment_intent.succeeded') {
            $paymentIntent = $event->data->object;
            $metadata = $paymentIntent->metadata;

            $userId = $metadata->user_id ?? null;
            $deliveryAddress = $metadata->delivery_address ?? '';
            $notes = $metadata->notes ?? '';

            if (!$userId) {
                return ['status' => 'ignored', 'reason' => 'missing user_id in metadata'];
            }

            $user = User::find($userId);
            if (!$user) {
                return ['status' => 'ignored', 'reason' => 'user not found'];
            }

            // Check if payment already processed
            $existingPayment = Payment::where('provider_ref', $paymentIntent->id)->first();
            if ($existingPayment) {
                return ['status' => 'ignored', 'reason' => 'payment already processed'];
            }

            $orderService = app(\App\Modules\Orders\Services\OrderService::class);
            
            try {
                $orderService->checkout(
                    $user, 
                    $deliveryAddress, 
                    $notes, 
                    Payment::METHOD_CARD, 
                    'stripe', 
                    $paymentIntent->id
                );
            } catch (\Exception $e) {
                // If cart is empty or unavailable, we log it and maybe handle it manually.
                // We return a 200 so Stripe doesn't retry infinitely, but we should alert admin.
                \Illuminate\Support\Facades\Log::error('Stripe webhook failed to create order: ' . $e->getMessage());
                return ['status' => 'error', 'reason' => $e->getMessage()];
            }

            return ['status' => 'processed'];
        }

        return ['status' => 'ignored', 'type' => $event->type];
    }

    public function confirmPaymentIntent(User $user, string $paymentIntentId): array
    {
        $stripe = new StripeClient(config('services.stripe.secret'));
        $paymentIntent = $stripe->paymentIntents->retrieve($paymentIntentId);

        if ($paymentIntent->status !== 'succeeded') {
            throw ValidationException::withMessages([
                'payment' => [__('Payment has not succeeded yet.')],
            ]);
        }

        $existingPayment = Payment::where('provider_ref', $paymentIntentId)->first();
        if ($existingPayment) {
            return ['status' => 'already_processed'];
        }

        $metadata = $paymentIntent->metadata;
        $deliveryAddress = $metadata->delivery_address ?? '';
        $notes = $metadata->notes ?? '';

        $orderService = app(\App\Modules\Orders\Services\OrderService::class);
        $orders = $orderService->checkout(
            $user, 
            $deliveryAddress, 
            $notes, 
            Payment::METHOD_CARD, 
            'stripe', 
            $paymentIntentId
        );

        return ['status' => 'processed', 'orders' => $orders];
    }
}
