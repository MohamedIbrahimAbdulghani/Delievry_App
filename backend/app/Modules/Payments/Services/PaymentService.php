<?php

namespace App\Modules\Payments\Services;

use App\Modules\Orders\Models\Order;
use App\Modules\Payments\Http\Resources\PaymentResource;
use App\Modules\Payments\Models\Payment;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class PaymentService
{
    /**
     * @return array{payment: PaymentResource, client_secret: null, message: string}
     */
    public function createIntent(Order $order, string $paymentMethod): array
    {
        $existing = $order->payments()
            ->where('method', $paymentMethod)
            ->where('status', Payment::STATUS_PENDING)
            ->orderByDesc('id')
            ->first();

        if ($existing) {
            return [
                'payment' => new PaymentResource($existing),
                'client_secret' => null,
                'message' => $paymentMethod === Payment::METHOD_COD
                    ? __('Cash on delivery payment is pending.')
                    : __('Use your payment provider to complete this order.'),
            ];
        }

        if ($paymentMethod === Payment::METHOD_COD) {
            $payment = Payment::query()->create([
                'order_id' => $order->id,
                'method' => Payment::METHOD_COD,
                'status' => Payment::STATUS_PENDING,
                'amount' => $order->total,
                'provider' => null,
                'provider_ref' => null,
                'meta' => ['cod' => true],
            ]);

            return [
                'payment' => new PaymentResource($payment),
                'client_secret' => null,
                'message' => __('Cash on delivery selected.'),
            ];
        }

        if ($paymentMethod === Payment::METHOD_CARD) {
            $payment = Payment::query()->create([
                'order_id' => $order->id,
                'method' => Payment::METHOD_CARD,
                'status' => Payment::STATUS_PENDING,
                'amount' => $order->total,
                'provider' => 'stub',
                'provider_ref' => 'stub_'.Str::uuid()->toString(),
                'meta' => [
                    'client_secret' => null,
                    'note' => __('Replace with real gateway integration.'),
                ],
            ]);

            return [
                'payment' => new PaymentResource($payment),
                'client_secret' => null,
                'message' => __('Payment intent placeholder created.'),
            ];
        }

        throw ValidationException::withMessages([
            'payment_method' => [__('Unsupported payment method.')],
        ]);
    }

    /**
     * @return array<string, mixed>
     */
    public function handleWebhook(array $payload): array
    {
        return [
            'received' => true,
            'payload_keys' => array_keys($payload),
            'note' => __('Verify provider signature before processing in production.'),
        ];
    }
}
