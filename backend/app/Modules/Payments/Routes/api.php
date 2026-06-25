<?php

use App\Modules\Payments\Http\Controllers\PaymentController;
use App\Modules\Payments\Http\Controllers\WebhookController;
use Illuminate\Support\Facades\Route;

Route::post('/payments/webhook', [WebhookController::class, 'handle']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/payments/checkout-intent', [\App\Modules\Payments\Http\Controllers\CheckoutIntentController::class, 'store']);
    Route::post('/payments/confirm', [\App\Modules\Payments\Http\Controllers\ConfirmPaymentController::class, 'store']);
    Route::post('/orders/{order}/payments/intent', [PaymentController::class, 'intent']);
    Route::get('/orders/{order}/payments', [PaymentController::class, 'index']);
});
