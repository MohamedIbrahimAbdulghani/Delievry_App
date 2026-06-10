<?php

namespace App\Modules\Payments\Http\Controllers;

use App\Modules\Payments\Services\PaymentService;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WebhookController
{
    public function __construct(
        protected PaymentService $paymentService,
    ) {}

    public function handle(Request $request): JsonResponse
    {
        $payload = $request->all();
        $data = $this->paymentService->handleWebhook(is_array($payload) ? $payload : []);

        return ApiResponse::success($data, __('Webhook received.'));
    }
}
