<?php

namespace App\Modules\Users\Repositories;

use App\Models\User;
use App\Support\Pagination\ListQuery;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class UserRepository
{
    /** @var array<int, string> */
    protected array $allowedSorts = ['id', 'name', 'email', 'created_at'];

    public function paginate(ListQuery $query): LengthAwarePaginator
    {
        $q = User::query();

        if (! empty($query->filters['name'])) {
            $q->where('name', 'like', '%'.addcslashes((string) $query->filters['name'], '%_\\').'%');
        }
        if (! empty($query->filters['email'])) {
            $q->where('email', 'like', '%'.addcslashes((string) $query->filters['email'], '%_\\').'%');
        }
        if (isset($query->filters['is_admin']) && $query->filters['is_admin'] !== '') {
            $q->where('is_admin', filter_var($query->filters['is_admin'], FILTER_VALIDATE_BOOLEAN));
        }

        $sort = in_array($query->sort, $this->allowedSorts, true) ? $query->sort : 'id';

        return $q->orderBy($sort, $query->direction)
            ->paginate($query->perPage, ['*'], 'page', $query->page);
    }
}
