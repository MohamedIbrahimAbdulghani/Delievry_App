<?php

namespace App\Modules\Orders\Repositories;

use App\Models\User;
use App\Modules\Orders\Models\Order;
use App\Support\Pagination\ListQuery;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class OrderRepository
{
    /** @var array<int, string> */
    protected array $allowedSorts = ['id', 'status', 'total', 'created_at', 'placed_at'];

    public function paginateFor(User $actor, ListQuery $query): LengthAwarePaginator
    {
        $q = Order::query()->with(['restaurant', 'items']);

        if ($actor->isDelivery()) {
            $q->where(function ($sub) use ($actor) {
                $sub->where('driver_id', $actor->id)
                    ->orWhere(function ($sub2) {
                        $sub2->whereNull('driver_id')
                             ->where('status', Order::STATUS_PREPARING);
                    });
            });
        } elseif (! $actor->isAdmin()) {
            $q->where('user_id', $actor->id);
        } elseif (! empty($query->filters['user_id'])) {
            $q->where('user_id', (int) $query->filters['user_id']);
        }

        if (! empty($query->filters['restaurant_id'])) {
            $q->where('restaurant_id', (int) $query->filters['restaurant_id']);
        }
        if (! empty($query->filters['status'])) {
            $q->where('status', (string) $query->filters['status']);
        }

        $sort = in_array($query->sort, $this->allowedSorts, true) ? $query->sort : 'id';

        return $q->orderBy($sort, $query->direction)
            ->paginate($query->perPage, ['*'], 'page', $query->page);
    }
}
