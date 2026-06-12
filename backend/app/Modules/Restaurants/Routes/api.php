<?php

use App\Modules\Restaurants\Http\Controllers\RestaurantController;
use Illuminate\Support\Facades\Route;

Route::get('/restaurants', [RestaurantController::class, 'index']);
Route::get('/restaurants/{restaurant}', [RestaurantController::class, 'show']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/restaurants/{restaurant}/reviews', [RestaurantController::class, 'storeReview']);
});

Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::post('/restaurants', [RestaurantController::class, 'store']);
    Route::match(['put', 'patch'], '/restaurants/{restaurant}', [RestaurantController::class, 'update']);
    Route::delete('/restaurants/{restaurant}', [RestaurantController::class, 'destroy']);
});
