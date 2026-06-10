<?php

namespace App\Modules\Orders\Services;

use App\Models\User;
use App\Modules\Cart\Repositories\CartRepository;
use App\Modules\Orders\Http\Resources\OrderResource;
use App\Modules\Orders\Models\Order;
use App\Modules\Orders\Models\OrderItem;
use App\Modules\Orders\Repositories\OrderRepository;
use App\Modules\Payments\Models\Payment;
use App\Modules\Restaurants\Models\Restaurant;
use App\Support\Pagination\ListQuery;
use App\Support\Pagination\PaginationPresenter;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderService
{
    public function __construct(
        protected OrderRepository $orders,
        protected CartRepository $carts,
    ) {}

    /**
     * @return array{items: array<int, mixed>, pagination: array<string, int>}
     */
    public function paginate(User $actor, ListQuery $query): array
    {
        $paginator = $this->orders->paginateFor($actor, $query);

        return PaginationPresenter::wrap(
            $paginator,
            OrderResource::collection($paginator->items())->resolve(),
        );
    }

    public function checkout(User $user, string $deliveryAddress, ?string $notes, string $paymentMethod): mixed
    {
        return DB::transaction(function () use ($user, $deliveryAddress, $notes, $paymentMethod) {
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

            // Check if all restaurants are active
            foreach (array_keys($itemsByRestaurant) as $rid) {
                $restaurant = Restaurant::query()->findOrFail($rid);
                if (! $restaurant->is_active) {
                    throw ValidationException::withMessages([
                        'cart' => [__('Restaurant ":name" is not accepting orders.', ['name' => $restaurant->name])],
                    ]);
                }
            }

            $createdOrders = [];

            foreach ($itemsByRestaurant as $rid => $lines) {
                $restaurant = Restaurant::query()->findOrFail($rid);
                $subtotal = 0.0;
                foreach ($lines as $line) {
                    $subtotal += (float) $line->product->price * (int) $line->quantity;
                }
                $subtotal = round($subtotal, 2);
                $deliveryFee = round((float) $restaurant->delivery_fee, 2);
                $total = round($subtotal + $deliveryFee, 2);

                $order = Order::query()->create([
                    'user_id' => $user->id,
                    'restaurant_id' => $restaurant->id,
                    'status' => Order::STATUS_PENDING,
                    'delivery_address' => $deliveryAddress,
                    'notes' => $notes,
                    'subtotal' => $subtotal,
                    'delivery_fee' => $deliveryFee,
                    'total' => $total,
                    'latitude' => 37.7749,
                    'longitude' => -122.4194,
                    'placed_at' => now(),
                ]);

                foreach ($lines as $line) {
                    $product = $line->product;
                    OrderItem::query()->create([
                        'order_id' => $order->id,
                        'product_id' => $product->id,
                        'product_name' => $product->name,
                        'unit_price' => $product->price,
                        'quantity' => $line->quantity,
                        'options' => $line->options,
                    ]);
                }

                Payment::query()->create([
                    'order_id' => $order->id,
                    'method' => $paymentMethod,
                    'status' => Payment::STATUS_PENDING,
                    'amount' => $total,
                    'provider' => null,
                    'provider_ref' => null,
                    'meta' => $paymentMethod === Payment::METHOD_CARD
                        ? ['awaiting_gateway' => true]
                        : ['cod' => true],
                ]);

                $createdOrders[] = $order->load(['items', 'restaurant', 'payments']);
            }

            $cart->items()->delete();

            return OrderResource::collection($createdOrders);
        });
    }

    public function updateStatus(Order $order, string $status): OrderResource
    {
        $order->status = $status;
        
        // Simulate driver moving on status update
        if ($status === 'processing') {
            $order->latitude = 37.7789;
            $order->longitude = -122.4214;
        } elseif ($status === 'delivered') {
            $order->latitude = 37.7849;
            $order->longitude = -122.4294;
        }
        
        $order->save();

        return new OrderResource($order->fresh()->load(['items', 'restaurant', 'payments']));
    }
}
