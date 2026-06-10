<?php

namespace App\Support\Pagination;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PaginationPresenter
{
    /**
     * @param  array<int, mixed>  $items
     * @return array{items: array<int, mixed>, pagination: array<string, int>}
     */
    public static function wrap(LengthAwarePaginator $paginator, array $items): array
    {
        return [
            'items' => $items,
            'pagination' => [
                'current_page' => $paginator->currentPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
                'last_page' => $paginator->lastPage(),
            ],
        ];
    }
}
