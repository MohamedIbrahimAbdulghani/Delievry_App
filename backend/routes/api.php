<?php

use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    require app_path('Modules/Auth/Routes/api.php');
    require app_path('Modules/Users/Routes/api.php');
    require app_path('Modules/Restaurants/Routes/api.php');
    require app_path('Modules/Products/Routes/api.php');
    require app_path('Modules/Cart/Routes/api.php');
    require app_path('Modules/Orders/Routes/api.php');
    require app_path('Modules/Payments/Routes/api.php');
    require app_path('Modules/Notifications/Routes/api.php');

    // Add this line
    Route::middleware('auth:sanctum')->post('/favorites/toggle/{restaurant}', [\App\Http\Controllers\Api\V1\FavoriteController::class, 'toggle']);
    Route::middleware('auth:sanctum')->get('/favorites', [\App\Http\Controllers\Api\V1\FavoriteController::class, 'index']);
});