<?php

namespace App\Modules\Payments\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Payments\Services\PaymentService;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CheckoutIntentController extends Controller
{
    public function __construct(
        protected PaymentService $paymentService,
    ) {}

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'delivery_address' => ['required', 'string', 'max:2000'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $data = $this->paymentService->createCheckoutIntent(
            $request->user(),
            $request->delivery_address,
            $request->notes
        );

        return ApiResponse::success($data, __('Checkout intent created.'));
    }
}
