<?php

namespace App\Modules\Payments\Http\Requests;

use App\Modules\Payments\Models\Payment;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class PaymentIntentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'payment_method' => ['required', 'string', Rule::in([Payment::METHOD_COD, Payment::METHOD_CARD])],
        ];
    }
}
