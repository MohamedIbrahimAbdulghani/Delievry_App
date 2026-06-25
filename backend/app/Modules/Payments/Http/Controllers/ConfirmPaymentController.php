<?php

namespace App\Modules\Payments\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Payments\Services\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConfirmPaymentController extends Controller
{
    public function __construct(protected PaymentService $paymentService) {}

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'payment_intent_id' => 'required|string',
        ]);

        $result = $this->paymentService->confirmPaymentIntent(
            $request->user(),
            $request->input('payment_intent_id')
        );

        return response()->json([
            'status' => true,
            'message' => 'Payment confirmed',
            'data' => $result,
        ]);
    }
}
