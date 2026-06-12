<?php

namespace App\Modules\Orders\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Orders\Http\Requests\StoreOrderRequest;
use App\Modules\Orders\Http\Requests\UpdateOrderStatusRequest;
use App\Modules\Orders\Http\Resources\OrderResource;
use App\Modules\Orders\Models\Order;
use App\Modules\Orders\Services\OrderService;
use App\Support\Pagination\ListQuery;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function __construct(
        protected OrderService $orderService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Order::class);

        $list = ListQuery::fromRequest($request, ['id', 'status', 'total', 'created_at', 'placed_at'], 'id');
        $data = $this->orderService->paginate($request->user(), $list);

        return ApiResponse::success($data);
    }

    public function store(StoreOrderRequest $request): JsonResponse
    {
        $this->authorize('create', Order::class);

        $order = $this->orderService->checkout(
            $request->user(),
            $request->validated('delivery_address'),
            $request->validated('notes'),
            $request->validated('payment_method'),
        );

        return ApiResponse::success($order, __('Order placed.'), 201);
    }

    public function show(Order $order): JsonResponse
    {
        $this->authorize('view', $order);

        return ApiResponse::success(new OrderResource($order->load(['items', 'restaurant', 'payments', 'driver'])));
    }

    public function reorder(Order $order): JsonResponse
    {
        $this->authorize('view', $order);

        $cart = $this->orderService->reorder($order, request()->user());

        return ApiResponse::success($cart, __('Order recreated in cart.'));
    }

    public function updateStatus(UpdateOrderStatusRequest $request, Order $order): JsonResponse
    {
        $this->authorize('updateStatus', $order);

        $resource = $this->orderService->updateStatus($order, $request->validated('status'));

        return ApiResponse::success($resource, __('Order status updated.'));
    }

    public function updateLocation(Request $request, Order $order): JsonResponse
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $this->authorize('update', $order); // Assuming driver can update their own assigned orders

        $order->update([
            'driver_latitude' => $request->latitude,
            'driver_longitude' => $request->longitude,
        ]);

        $driver = $request->user();
        if ($driver && $driver->role === 'delivery') {
            $driver->update([
                'latitude' => $request->latitude,
                'longitude' => $request->longitude,
            ]);
        }

        $customerLat = $order->latitude;
        $customerLng = $order->longitude;

        if ($customerLat && $customerLng) {
            $latDiff = abs($request->latitude - $customerLat);
            $lngDiff = abs($request->longitude - $customerLng);

            if ($latDiff <= 0.0005 && $lngDiff <= 0.0005) {
                $exists = \App\Modules\Notifications\Models\Notification::where('user_id', $order->user_id)
                    ->where('title', 'Order Arrived')
                    ->where('body', 'like', "%Order #{$order->id}%")
                    ->exists();

                if (!$exists) {
                    \App\Modules\Notifications\Models\Notification::create([
                        'user_id' => $order->user_id,
                        'title' => 'Order Arrived',
                        'body' => "Your order #{$order->id} has arrived and is ready for pickup.",
                        'is_read' => false,
                    ]);
                }
            }
        }

        return ApiResponse::success(new OrderResource($order->load(['items', 'restaurant', 'payments', 'driver'])), __('Order location updated.'));
    }

    public function assignDriver(Request $request, Order $order): JsonResponse
    {
        $request->validate([
            'driver_id' => 'required|exists:users,id',
        ]);

        $driver = \App\Models\User::findOrFail($request->driver_id);
        if ($driver->role !== 'delivery') {
            return ApiResponse::error(__('User is not a delivery driver.'), [], 422);
        }

        $order->update([
            'driver_id' => $request->driver_id,
        ]);

        return ApiResponse::success(new OrderResource($order->load(['items', 'restaurant', 'driver'])), __('Driver assigned to order.'));
    }

    public function earnings(Request $request): JsonResponse
    {
        $driver = $request->user();
        
        $allDelivered = Order::where('driver_id', $driver->id)
            ->where('status', Order::STATUS_DELIVERED)
            ->get();

        $todayDelivered = Order::where('driver_id', $driver->id)
            ->where('status', Order::STATUS_DELIVERED)
            ->whereDate('placed_at', today())
            ->get();

        $startOfWeek = now()->startOfWeek();
        $weekDelivered = Order::where('driver_id', $driver->id)
            ->where('status', Order::STATUS_DELIVERED)
            ->where('placed_at', '>=', $startOfWeek)
            ->get();

        $startOfMonth = now()->startOfMonth();
        $monthDelivered = Order::where('driver_id', $driver->id)
            ->where('status', Order::STATUS_DELIVERED)
            ->where('placed_at', '>=', $startOfMonth)
            ->get();

        $data = [
            'today_deliveries' => $todayDelivered->count(),
            'today_earnings' => (double) $todayDelivered->sum('delivery_fee'),
            'weekly_deliveries' => $weekDelivered->count(),
            'weekly_earnings' => (double) $weekDelivered->sum('delivery_fee'),
            'monthly_deliveries' => $monthDelivered->count(),
            'monthly_earnings' => (double) $monthDelivered->sum('delivery_fee'),
            'total_deliveries' => $allDelivered->count(),
            'total_earnings' => (double) $allDelivered->sum('delivery_fee'),
        ];

        return ApiResponse::success($data);
    }

    public function history(Request $request): JsonResponse
    {
        $driver = $request->user();
        $list = ListQuery::fromRequest($request, ['id', 'status', 'total', 'created_at', 'placed_at'], 'id');

        $paginator = Order::where('driver_id', $driver->id)
            ->whereIn('status', [Order::STATUS_DELIVERED, Order::STATUS_FAILED, Order::STATUS_CANCELLED])
            ->orderBy($list->sort, $list->direction)
            ->paginate($list->perPage, ['*'], 'page', $list->page);

        $data = \App\Support\Pagination\PaginationPresenter::wrap(
            $paginator,
            OrderResource::collection($paginator->items())->resolve(),
        );

        return ApiResponse::success($data);
    }
}
