<?php

namespace App\Modules\Products\Services;

use App\Modules\Products\Http\Resources\ProductResource;
use App\Modules\Products\Models\Product;
use App\Modules\Products\Repositories\ProductRepository;
use App\Support\Pagination\ListQuery;
use App\Support\Pagination\PaginationPresenter;
use Illuminate\Support\Str;

class ProductService
{
    public function __construct(
        protected ProductRepository $products,
    ) {}

    /**
     * @return array{items: array<int, mixed>, pagination: array<string, int>}
     */
    public function paginate(ListQuery $query): array
    {
        $paginator = $this->products->paginate($query);

        return PaginationPresenter::wrap(
            $paginator,
            ProductResource::collection($paginator->items())->resolve(),
        );
    }

    public function create(array $data): ProductResource
    {
        $baseSlug = ! empty($data['slug']) ? Str::slug($data['slug']) : Str::slug($data['name']);
        if ($baseSlug === '') {
            $baseSlug = 'item';
        }
        $slug = $this->uniqueSlug((int) $data['restaurant_id'], $baseSlug);

        $product = Product::query()->create([
            'restaurant_id' => $data['restaurant_id'],
            'name' => $data['name'],
            'slug' => $slug,
            'description' => $data['description'] ?? null,
            'price' => $data['price'],
            'category' => $data['category'] ?? null,
            'is_available' => $data['is_available'] ?? true,
            'image_url' => $data['image_url'] ?? null,
        ]);

        return new ProductResource($product->load('restaurant'));
    }

    public function update(Product $product, array $data): ProductResource
    {
        $restaurantId = (int) ($data['restaurant_id'] ?? $product->restaurant_id);

        if (isset($data['slug'])) {
            $base = Str::slug($data['slug']);
            $data['slug'] = $this->uniqueSlug($restaurantId, $base !== '' ? $base : $product->slug, $product->id);
        } elseif (isset($data['name'])) {
            $data['slug'] = $this->uniqueSlug($restaurantId, Str::slug($data['name']), $product->id);
        }

        $product->fill($data);
        if (isset($data['restaurant_id'])) {
            $product->restaurant_id = $restaurantId;
        }
        $product->save();

        return new ProductResource($product->fresh()->load('restaurant'));
    }

    public function delete(Product $product): void
    {
        $product->delete();
    }

    protected function uniqueSlug(int $restaurantId, string $base, ?int $ignoreId = null): string
    {
        $slug = $base;
        $i = 1;
        while (Product::query()
            ->where('restaurant_id', $restaurantId)
            ->when($ignoreId, fn ($q) => $q->where('id', '!=', $ignoreId))
            ->where('slug', $slug)
            ->exists()) {
            $slug = $base.'-'.$i++;
        }

        return $slug;
    }
}
