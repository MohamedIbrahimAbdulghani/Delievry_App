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
use App\Modules\Notifications\Models\Notification;
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

                // Create admin notifications for new order
                $admins = \App\Models\User::where('is_admin', true)->get();
                foreach ($admins as $admin) {
                    Notification::create([
                        'user_id' => $admin->id,
                        'title' => 'New Order Placed',
                        'body' => "New order #{$order->id} of amount \${$total} has been placed from {$restaurant->name}.",
                        'is_read' => false,
                        'restaurant_id' => $restaurant->id,
                        'order_id' => $order->id,
                    ]);
                }

                $createdOrders[] = $order->load(['items', 'restaurant', 'payments']);
            }

            $cart->items()->delete();

            return OrderResource::collection($createdOrders);
        });
    }

    /**
     * Validate status transition.
     */
    public static function isValidTransition(string $from, string $to): bool
    {
        $valid = [
            Order::STATUS_PENDING => [Order::STATUS_PREPARING, Order::STATUS_CANCELLED],
            Order::STATUS_PREPARING => [Order::STATUS_HEADING_TO_RESTAURANT, Order::STATUS_CANCELLED],
            Order::STATUS_HEADING_TO_RESTAURANT => [Order::STATUS_PICKED_UP, Order::STATUS_PREPARING, Order::STATUS_CANCELLED],
            Order::STATUS_PICKED_UP => [Order::STATUS_OUT_FOR_DELIVERY, Order::STATUS_FAILED, Order::STATUS_CANCELLED],
            Order::STATUS_OUT_FOR_DELIVERY => [Order::STATUS_DELIVERED, Order::STATUS_FAILED, Order::STATUS_CANCELLED],
            Order::STATUS_DELIVERED => [],
            Order::STATUS_FAILED => [],
            Order::STATUS_CANCELLED => [],
        ];
        return in_array($to, $valid[$from] ?? [], true);
    }

    public function updateStatus(Order $order, string $status): OrderResource
    {
        if ($order->status !== $status) {
            if (!self::isValidTransition($order->status, $status)) {
                throw ValidationException::withMessages([
                    'status' => [__('Invalid status transition from :from to :to.', ['from' => $order->status, 'to' => $status])],
                ]);
            }

            $actor = auth()->user();
            if ($actor && $actor->role === 'delivery' && $status === Order::STATUS_PREPARING) {
                // Driver rejected assignment
                $order->driver_id = null;
                $order->driver_latitude = null;
                $order->driver_longitude = null;
            }

            $order->status = $status;

            // Simulate driver moving on status update
            if ($status === Order::STATUS_HEADING_TO_RESTAURANT || $status === Order::STATUS_OUT_FOR_DELIVERY) {
                $order->driver_latitude = 37.7789;
                $order->driver_longitude = -122.4214;
            } elseif ($status === Order::STATUS_DELIVERED) {
                $order->driver_latitude = 37.7849;
                $order->driver_longitude = -122.4294;

                // Create customer notification when status changes to Delivered
                $notificationExists = Notification::where('order_id', $order->id)
                    ->where('title', 'Order Delivered')
                    ->exists();

                if (!$notificationExists) {
                    Notification::create([
                        'user_id' => $order->user_id,
                        'title' => 'Order Delivered',
                        'body' => 'Your order has arrived successfully. Please rate your experience and leave a review.',
                        'is_read' => false,
                        'is_rated' => false,
                        'restaurant_id' => $order->restaurant_id,
                        'order_id' => $order->id,
                    ]);

                    // Send push notification simulation
                    $customer = $order->user;
                    if ($customer && $customer->device_token) {
                        \Illuminate\Support\Facades\Log::info("Push notification sent to device token: {$customer->device_token}", [
                            'title' => 'Order Delivered',
                            'body' => 'Your order has arrived successfully. Please rate your experience and leave a review.',
                            'order_id' => $order->id,
                        ]);
                    } else {
                        \Illuminate\Support\Facades\Log::warning("Customer has no device token. Skipping push notification for user_id: {$order->user_id}");
                    }
                }
            }

            // Suppressed customer notifications on status update (customer only receives notification upon driver arrival)

            if ($status === Order::STATUS_PREPARING) {
                // Find all active drivers/delivery users
                $activeDrivers = \App\Models\User::whereIn('role', ['driver', 'delivery'])
                    ->where('is_online', true)
                    ->get();

                foreach ($activeDrivers as $driver) {
                    Notification::create([
                        'user_id' => $driver->id,
                        'title' => 'New Delivery Request',
                        'body' => "New order #{$order->id} is available for delivery from {$order->restaurant->name}.",
                        'is_read' => false,
                        'restaurant_id' => $order->restaurant_id,
                        'order_id' => $order->id,
                    ]);
                }
            }

            $order->save();
        }

        return new OrderResource($order->fresh()->load(['items', 'restaurant', 'payments', 'driver']));
    }

    public function acceptOrder(Order $order, User $driver): OrderResource
    {
        return DB::transaction(function () use ($order, $driver) {
            // Pessimistic locking to prevent race conditions
            $lockedOrder = Order::lockForUpdate()->findOrFail($order->id);

            if ($lockedOrder->driver_id !== null) {
                throw ValidationException::withMessages([
                    'driver' => [__('This order has already been accepted by another driver.')],
                ]);
            }

            if ($lockedOrder->status !== Order::STATUS_PREPARING) {
                throw ValidationException::withMessages([
                    'status' => [__('This order cannot be accepted in its current status.')],
                ]);
            }

            $lockedOrder->update([
                'driver_id' => $driver->id,
                'status' => Order::STATUS_HEADING_TO_RESTAURANT,
                'driver_latitude' => 37.7789,
                'driver_longitude' => -122.4214,
            ]);

            // Hide from other drivers: delete notifications for other drivers
            Notification::where('order_id', $lockedOrder->id)
                ->where('user_id', '!=', $driver->id)
                ->delete();

            // Also delete the notification for the assigned driver to clear their screen
            Notification::where('order_id', $lockedOrder->id)
                ->where('user_id', $driver->id)
                ->delete();

            // Suppressed customer notification when driver accepts order (customer only receives notification upon driver arrival)

            return new OrderResource($lockedOrder->fresh()->load(['items', 'restaurant', 'payments', 'driver']));
        });
    }

    public function reorder(Order $order, User $user): \App\Modules\Cart\Http\Resources\CartResource
    {
        return DB::transaction(function () use ($order, $user) {
            $cart = $this->carts->getOrCreateForUser($user);
            $cart->items()->delete();

            $order->load('items');

            foreach ($order->items as $item) {
                $product = \App\Modules\Products\Models\Product::find($item->product_id);
                if ($product && $product->is_available) {
                    \App\Modules\Cart\Models\CartItem::create([
                        'cart_id' => $cart->id,
                        'product_id' => $item->product_id,
                        'quantity' => $item->quantity,
                        'options' => $item->options,
                    ]);
                }
            }

            $this->carts->loadWithItems($cart);

            return new \App\Modules\Cart\Http\Resources\CartResource($cart);
        });
    }
}
