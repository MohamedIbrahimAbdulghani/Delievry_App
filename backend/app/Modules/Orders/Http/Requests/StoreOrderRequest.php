<?php

namespace App\Modules\Orders\Http\Requests;

use App\Modules\Payments\Models\Payment;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreOrderRequest extends FormRequest
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
            'delivery_address' => ['required', 'string', 'max:2000'],
            'notes' => ['nullable', 'string', 'max:2000'],
            'payment_method' => ['required', 'string', Rule::in([Payment::METHOD_COD, Payment::METHOD_CARD])],
        ];
    }
}
