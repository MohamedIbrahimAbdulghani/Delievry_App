<?php

namespace App\Modules\Users\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Modules\Users\Http\Requests\StoreUserRequest;
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

    public function store(StoreUserRequest $request): JsonResponse
    {
        $this->authorize('create', User::class);

        $resource = $this->userService->create($request->validated());

        return ApiResponse::success($resource, __('User created.'), 201);
    }

    public function destroy(User $user): JsonResponse
    {
        $this->authorize('delete', $user);

        $this->userService->delete($user, request()->user());

        return ApiResponse::success([], __('User deleted.'));
    }

    public function toggleAvailability(Request $request): JsonResponse
    {
        $user = $request->user();
        if ($user->role !== 'delivery') {
            return ApiResponse::error(__('Unauthorized.'), [], 403);
        }

        $request->validate([
            'is_online' => 'required|boolean',
        ]);

        $user->update([
            'is_online' => $request->is_online,
        ]);

        return ApiResponse::success(new UserResource($user), __('Availability updated.'));
    }

    public function updateDeviceToken(Request $request): JsonResponse
    {
        $request->validate([
            'device_token' => 'required|string',
        ]);

        $request->user()->update([
            'device_token' => $request->device_token,
        ]);

        return ApiResponse::success([], __('Device token updated successfully.'));
    }
}
