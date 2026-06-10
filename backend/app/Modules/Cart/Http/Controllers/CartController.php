<?php

namespace App\Modules\Cart\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Cart\Http\Requests\StoreCartItemRequest;
use App\Modules\Cart\Http\Requests\UpdateCartItemRequest;
use App\Modules\Cart\Services\CartService;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function __construct(
        protected CartService $cartService,
    ) {}

    public function show(Request $request): JsonResponse
    {
        return ApiResponse::success($this->cartService->getCart($request->user()));
    }

    public function addItem(StoreCartItemRequest $request): JsonResponse
    {
        $cart = $this->cartService->addItem(
            $request->user(),
            (int) $request->validated('product_id'),
            (int) $request->validated('quantity'),
            $request->validated('options'),
        );

        return ApiResponse::success($cart, __('Item added to cart.'));
    }

    public function updateItem(UpdateCartItemRequest $request, int $lineId): JsonResponse
    {
        $cart = $this->cartService->updateItem(
            $request->user(),
            $lineId,
            (int) $request->validated('quantity'),
            $request->validated('options'),
        );

        return ApiResponse::success($cart, __('Cart updated.'));
    }

    public function removeItem(Request $request, int $lineId): JsonResponse
    {
        $cart = $this->cartService->removeItem($request->user(), $lineId);

        return ApiResponse::success($cart, __('Item removed.'));
    }

    public function clear(Request $request): JsonResponse
    {
        $cart = $this->cartService->clear($request->user());

        return ApiResponse::success($cart, __('Cart cleared.'));
    }
}
