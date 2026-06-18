<?php

namespace App\Support\Pagination;

use Illuminate\Http\Request;

class ListQuery
{
    public function __construct(
        public readonly int $page,
        public readonly int $perPage,
        public readonly ?string $sort,
        public readonly string $direction,
        /** @var array<string, mixed> */
        public readonly array $filters,
    ) {}

    public static function fromRequest(Request $request, array $allowedSorts, string $defaultSort = 'id'): self
    {
        $page = max(1, (int) $request->query('page', 1));
        $perPage = min(100, max(1, (int) $request->query('per_page', 15)));
        $sort = $request->query('sort', $defaultSort);
        if (! is_string($sort) || ! in_array($sort, $allowedSorts, true)) {
            $sort = $defaultSort;
        }
        $direction = strtolower((string) $request->query('direction', 'desc'));
        if (! in_array($direction, ['asc', 'desc'], true)) {
            $direction = 'desc';
        }

        $filters = [];
        $filterData = $request->query('filter');
        if (is_array($filterData)) {
            $filters = $filterData;
        } else {
            $all = $request->query();
            foreach ($all as $key => $value) {
                if (str_starts_with($key, 'filter[') && str_ends_with($key, ']')) {
                    $inner = substr($key, 7, -1);
                    if ($inner !== '') {
                        $filters[$inner] = $value;
                    }
                }
            }
        }

        return new self($page, $perPage, $sort, $direction, $filters);
    }
}
