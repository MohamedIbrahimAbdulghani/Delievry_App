<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Modules\Restaurants\Models\Restaurant;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $isAdmin = $user && ($user->is_admin || $user->role === 'admin');

        $favoritesQuery = Favorite::where('user_id', $user->id);

        if (!$isAdmin) {
            $favoritesQuery->whereHas('restaurant', function ($query) {
                $query->where('is_active', true);
            });
        }

        $favorites = $favoritesQuery->with('restaurant')->get();
            
        $formatted = $favorites->map(function ($fav) {
            return [
                'id' => $fav->id,
                'restaurant' => new \App\Modules\Restaurants\Http\Resources\RestaurantResource($fav->restaurant),
                'meal' => null
            ];
        });

        return ApiResponse::success($formatted);
    }

    public function toggle(Request $request, Restaurant $restaurant): JsonResponse
    {
        $user = $request->user();
        
        $favorite = Favorite::where('user_id', $user->id)
            ->where('restaurant_id', $restaurant->id)
            ->first();

        if ($favorite) {
            $favorite->delete();
            return ApiResponse::success(['is_favorite' => false], __('Removed from favorites.'));
        } else {
            Favorite::create([
                'user_id' => $user->id,
                'restaurant_id' => $restaurant->id,
            ]);
            return ApiResponse::success(['is_favorite' => true], __('Added to favorites.'));
        }
    }
}
