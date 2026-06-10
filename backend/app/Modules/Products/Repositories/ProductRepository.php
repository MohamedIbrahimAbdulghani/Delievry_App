<?php

namespace App\Modules\Products\Repositories;

use App\Modules\Products\Models\Product;
use App\Support\Pagination\ListQuery;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ProductRepository
{
    /** @var array<int, string> */
    protected array $allowedSorts = ['id', 'name', 'price', 'created_at', 'category'];

    public function paginate(ListQuery $query): LengthAwarePaginator
    {
        $q = Product::query()->with('restaurant');

        if (! empty($query->filters['restaurant_id'])) {
            $q->where('restaurant_id', (int) $query->filters['restaurant_id']);
        }
        if (! empty($query->filters['category'])) {
            $q->where('category', (string) $query->filters['category']);
        }
        if (isset($query->filters['is_available']) && $query->filters['is_available'] !== '') {
            $q->where('is_available', filter_var($query->filters['is_available'], FILTER_VALIDATE_BOOLEAN));
        }
        if (! empty($query->filters['price_min'])) {
            $q->where('price', '>=', (float) $query->filters['price_min']);
        }
        if (! empty($query->filters['price_max'])) {
            $q->where('price', '<=', (float) $query->filters['price_max']);
        }
        if (! empty($query->filters['search'])) {
            $term = '%'.addcslashes((string) $query->filters['search'], '%_\\').'%';
            $q->where(function ($inner) use ($term) {
                $inner->where('name', 'like', $term)
                    ->orWhere('description', 'like', $term);
            });
        }

        $sort = in_array($query->sort, $this->allowedSorts, true) ? $query->sort : 'id';

        return $q->orderBy($sort, $query->direction)
            ->paginate($query->perPage, ['*'], 'page', $query->page);
    }
}
