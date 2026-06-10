<?php

namespace App\Modules\Payments\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Orders\Models\Order;
use App\Modules\Payments\Http\Requests\PaymentIntentRequest;
use App\Modules\Payments\Http\Resources\PaymentResource;
use App\Modules\Payments\Services\PaymentService;
use App\Support\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function __construct(
        protected PaymentService $paymentService,
    ) {}

    public function intent(PaymentIntentRequest $request, Order $order): JsonResponse
    {
        $this->authorize('managePayments', $order);

        $data = $this->paymentService->createIntent($order, $request->validated('payment_method'));

        return ApiResponse::success($data, $data['message']);
    }

    public function index(Request $request, Order $order): JsonResponse
    {
        $this->authorize('managePayments', $order);

        $payments = $order->payments()->orderByDesc('id')->get();

        return ApiResponse::success(PaymentResource::collection($payments));
    }
}
