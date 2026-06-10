<?php

use App\Modules\Cart\Http\Controllers\CartController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/cart', [CartController::class, 'show']);
    Route::post('/cart/items', [CartController::class, 'addItem']);
    Route::match(['patch', 'put'], '/cart/items/{lineId}', [CartController::class, 'updateItem']);
    Route::delete('/cart/items/{lineId}', [CartController::class, 'removeItem']);
    Route::delete('/cart', [CartController::class, 'clear']);
});
