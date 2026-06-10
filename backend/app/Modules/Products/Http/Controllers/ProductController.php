<?php

namespace App\Modules\Products\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Products\Http\Requests\StoreProductRequest;
use App\Modules\Products\Http\Requests\UpdateProductRequest;
use App\Modules\Products\Http\Resources\ProductResource;
use App\Modules\Products\Models\Product;
use App\Modules\Products\Services\ProductService;
use App\Support\Pagination\ListQuery;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function __construct(
        protected ProductService $productService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Product::class);

        $list = ListQuery::fromRequest($request, ['id', 'name', 'price', 'created_at', 'category'], 'id');
        $data = $this->productService->paginate($list);

        return ApiResponse::success($data);
    }

    public function show(Product $product): JsonResponse
    {
        $this->authorize('view', $product);

        return ApiResponse::success(new ProductResource($product->load('restaurant')));
    }

    public function store(StoreProductRequest $request): JsonResponse
    {
        $this->authorize('create', Product::class);

        $resource = $this->productService->create($request->validated());

        return ApiResponse::success($resource, __('Product created.'), 201);
    }

    public function update(UpdateProductRequest $request, Product $product): JsonResponse
    {
        $this->authorize('update', $product);

        $resource = $this->productService->update($product, $request->validated());

        return ApiResponse::success($resource, __('Product updated.'));
    }

    public function destroy(Product $product): JsonResponse
    {
        $this->authorize('delete', $product);

        $this->productService->delete($product);

        return ApiResponse::success([], __('Product deleted.'));
    }
}
