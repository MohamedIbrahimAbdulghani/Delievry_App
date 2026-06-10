<?php

namespace App\Modules\Users\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Modules\Users\Http\Requests\UpdateUserRequest;
use App\Modules\Users\Http\Resources\UserResource;
use App\Modules\Users\Services\UserService;
use App\Support\Pagination\ListQuery;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function __construct(
        protected UserService $userService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', User::class);

        $list = ListQuery::fromRequest($request, ['id', 'name', 'email', 'created_at'], 'id');
        $data = $this->userService->paginateForAdmin($list);

        return ApiResponse::success($data);
    }

    public function show(User $user): JsonResponse
    {
        $this->authorize('view', $user);

        return ApiResponse::success(new UserResource($user));
    }

    public function update(UpdateUserRequest $request, User $user): JsonResponse
    {
        $this->authorize('update', $user);

        $resource = $this->userService->update($user, $request->user(), $request->validated());

        return ApiResponse::success($resource, __('User updated.'));
    }

    public function destroy(User $user): JsonResponse
    {
        $this->authorize('delete', $user);

        $this->userService->delete($user, request()->user());

        return ApiResponse::success([], __('User deleted.'));
    }
}
