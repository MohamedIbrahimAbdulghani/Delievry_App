<?php

use App\Modules\Orders\Http\Controllers\OrderController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::patch('/orders/{order}/location', [OrderController::class, 'updateLocation']);
    Route::post('/orders/{order}/reorder', [OrderController::class, 'reorder']);
});

Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);
    Route::patch('/orders/{order}/assign', [OrderController::class, 'assignDriver']);
});

Route::middleware(['auth:sanctum', 'delivery'])->prefix('delivery')->group(function () {
    Route::get('/orders', [OrderController::class, 'index']);
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);
    Route::patch('/orders/{order}/location', [OrderController::class, 'updateLocation']);
    Route::post('/availability', [\App\Modules\Users\Http\Controllers\UserController::class, 'toggleAvailability']);
    Route::get('/earnings', [OrderController::class, 'earnings']);
    Route::get('/history', [OrderController::class, 'history']);
});
