<?php

namespace App\Modules\Restaurants\Services;

use App\Modules\Restaurants\Http\Resources\RestaurantResource;
use App\Modules\Restaurants\Models\Restaurant;
use App\Modules\Restaurants\Repositories\RestaurantRepository;
use App\Support\Pagination\ListQuery;
use App\Support\Pagination\PaginationPresenter;
use Illuminate\Support\Str;

class RestaurantService
{
    public function __construct(
        protected RestaurantRepository $restaurants,
    ) {}

    /**
     * @return array{items: array<int, mixed>, pagination: array<string, int>}
     */
    public function paginate(ListQuery $query): array
    {
        $paginator = $this->restaurants->paginate($query);

        return PaginationPresenter::wrap(
            $paginator,
            RestaurantResource::collection($paginator->items())->resolve(),
        );
    }

    public function create(array $data): RestaurantResource
    {
        $baseSlug = ! empty($data['slug']) ? Str::slug($data['slug']) : Str::slug($data['name']);
        if ($baseSlug === '') {
            $baseSlug = 'restaurant';
        }
        $slug = $this->uniqueSlug($baseSlug);

        $restaurant = Restaurant::query()->create([
            'name' => $data['name'],
            'slug' => $slug,
            'city' => $data['city'] ?? null,
            'address' => $data['address'] ?? null,
            'phone' => $data['phone'] ?? null,
            'delivery_fee' => $data['delivery_fee'] ?? 0,
            'is_active' => $data['is_active'] ?? true,
            'image_url' => $data['image_url'] ?? null,
        ]);

        return new RestaurantResource($restaurant);
    }

    public function update(Restaurant $restaurant, array $data): RestaurantResource
    {
        if (isset($data['slug'])) {
            $base = Str::slug($data['slug']);
            $data['slug'] = $this->uniqueSlug($base !== '' ? $base : $restaurant->slug, $restaurant->id);
        } elseif (isset($data['name'])) {
            $data['slug'] = $this->uniqueSlug(Str::slug($data['name']), $restaurant->id);
        }

        $restaurant->fill($data);
        $restaurant->save();

        return new RestaurantResource($restaurant->fresh());
    }

    public function delete(Restaurant $restaurant): void
    {
        $restaurant->delete();
    }

    protected function uniqueSlug(string $base, ?int $ignoreId = null): string
    {
        $slug = $base;
        $i = 1;
        while (Restaurant::query()
            ->when($ignoreId, fn ($q) => $q->where('id', '!=', $ignoreId))
            ->where('slug', $slug)
            ->exists()) {
            $slug = $base.'-'.$i++;
        }

        return $slug;
    }
}
