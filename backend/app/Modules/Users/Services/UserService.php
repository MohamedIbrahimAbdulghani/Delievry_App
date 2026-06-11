<?php

namespace App\Modules\Users\Services;

use App\Models\User;
use App\Modules\Users\Http\Resources\UserResource;
use App\Modules\Users\Repositories\UserRepository;
use App\Support\Pagination\ListQuery;
use App\Support\Pagination\PaginationPresenter;

class UserService
{
    public function __construct(
        protected UserRepository $users,
    ) {}

    /**
     * @return array{items: array<int, mixed>, pagination: array<string, int>}
     */
    public function paginateForAdmin(ListQuery $query): array
    {
        $paginator = $this->users->paginate($query);

        return PaginationPresenter::wrap(
            $paginator,
            UserResource::collection($paginator->items())->resolve(),
        );
    }

    public function create(array $data): UserResource
    {
        $user = User::query()->create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
            'is_admin' => $data['is_admin'] ?? false,
        ]);

        return new UserResource($user);
    }

    public function update(User $target, User $actor, array $data): UserResource
    {
        if (array_key_exists('is_admin', $data) && ! $actor->is_admin) {
            unset($data['is_admin']);
        }

        $password = $data['password'] ?? null;
        unset($data['password']);

        $target->fill($data);
        if (! empty($password)) {
            $target->password = $password;
        }
        $target->save();

        return new UserResource($target->fresh());
    }

    public function delete(User $target, User $actor): void
    {
        if ($actor->id === $target->id) {
            abort(403);
        }
        $target->delete();
    }
}
