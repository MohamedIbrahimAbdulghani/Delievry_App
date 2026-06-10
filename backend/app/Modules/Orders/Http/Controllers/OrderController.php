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

        return ApiResponse::success(new OrderResource($order->load(['items', 'restaurant', 'payments'])));
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
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
        ]);

        return ApiResponse::success(new OrderResource($order), __('Order location updated.'));
    }
}
