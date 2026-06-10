<?php

use App\Modules\Orders\Http\Controllers\OrderController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::patch('/orders/{order}/location', [OrderController::class, 'updateLocation']);
});

Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);
});
