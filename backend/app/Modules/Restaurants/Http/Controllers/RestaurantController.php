<?php

namespace App\Modules\Restaurants\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Restaurants\Http\Requests\StoreRestaurantRequest;
use App\Modules\Restaurants\Http\Requests\UpdateRestaurantRequest;
use App\Modules\Restaurants\Http\Resources\RestaurantResource;
use App\Modules\Restaurants\Http\Resources\ReviewResource;
use App\Modules\Notifications\Models\Notification;
use App\Modules\Restaurants\Models\Restaurant;
use App\Modules\Restaurants\Services\RestaurantService;
use App\Support\Pagination\ListQuery;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RestaurantController extends Controller
{
    public function __construct(
        protected RestaurantService $restaurantService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Restaurant::class);

        $list = ListQuery::fromRequest($request, ['id', 'name', 'city', 'created_at'], 'id');
        $data = $this->restaurantService->paginate($list);

        return ApiResponse::success($data);
    }

    public function show(Restaurant $restaurant): JsonResponse
    {
        $this->authorize('view', $restaurant);

        return ApiResponse::success(new RestaurantResource($restaurant->load(['products', 'reviews.user'])));
    }

    public function storeReview(Request $request, Restaurant $restaurant): JsonResponse
    {
        $request->validate([
            'rating' => 'required|numeric|min:1|max:5',
            'comment' => 'nullable|string',
            'notification_id' => 'nullable|exists:notifications,id',
        ]);

        $review = $restaurant->reviews()->create([
            'user_id' => auth()->id(),
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        if ($request->notification_id) {
            $notification = Notification::where('id', $request->notification_id)
                ->where('user_id', auth()->id())
                ->first();
            if ($notification) {
                $notification->update(['is_rated' => true]);
            }
        }

        return ApiResponse::success(new ReviewResource($review->load('user')), __('Review submitted successfully.'));
    }

    public function store(StoreRestaurantRequest $request): JsonResponse
    {
        $this->authorize('create', Restaurant::class);

        $resource = $this->restaurantService->create($request->validated());

        return ApiResponse::success($resource, __('Restaurant created.'), 201);
    }

    public function update(UpdateRestaurantRequest $request, Restaurant $restaurant): JsonResponse
    {
        $this->authorize('update', $restaurant);

        $resource = $this->restaurantService->update($restaurant, $request->validated());

        return ApiResponse::success($resource, __('Restaurant updated.'));
    }

    public function destroy(Restaurant $restaurant): JsonResponse
    {
        $this->authorize('delete', $restaurant);

        $this->restaurantService->delete($restaurant);

        return ApiResponse::success([], __('Restaurant deleted.'));
    }
}
