<?php

namespace App\Modules\Restaurants\Repositories;

use App\Modules\Restaurants\Models\Restaurant;
use App\Support\Pagination\ListQuery;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class RestaurantRepository
{
    /** @var array<int, string> */
    protected array $allowedSorts = ['id', 'name', 'city', 'created_at'];

    public function paginate(ListQuery $query): LengthAwarePaginator
    {
        $q = Restaurant::query();

        if (! empty($query->filters['name'])) {
            $q->where('name', 'like', '%'.addcslashes((string) $query->filters['name'], '%_\\').'%');
        }
        if (! empty($query->filters['city'])) {
            $q->where('city', 'like', '%'.addcslashes((string) $query->filters['city'], '%_\\').'%');
        }
        if (! empty($query->filters['category'])) {
            $categoryName = (string) $query->filters['category'];
            $q->whereHas('products', function ($inner) use ($categoryName) {
                $inner->where('category', $categoryName);
            });
        }
        if (isset($query->filters['is_active']) && $query->filters['is_active'] !== '') {
            $q->where('is_active', filter_var($query->filters['is_active'], FILTER_VALIDATE_BOOLEAN));
        }

        $sort = in_array($query->sort, $this->allowedSorts, true) ? $query->sort : 'id';

        return $q->orderBy($sort, $query->direction)
            ->paginate($query->perPage, ['*'], 'page', $query->page);
    }
}
