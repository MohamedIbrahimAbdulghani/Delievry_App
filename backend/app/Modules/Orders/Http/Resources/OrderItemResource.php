<?php

namespace App\Modules\Orders\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Orders\Models\OrderItem */
class OrderItemResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'product_name' => $this->product_name,
            'product_name_en' => $this->product ? $this->product->getTranslation('name', 'en', false) : $this->product_name,
            'product_name_ar' => $this->product ? $this->product->getTranslation('name', 'ar', false) : $this->product_name,
            'unit_price' => (string) $this->unit_price,
            'quantity' => (int) $this->quantity,
            'options' => $this->options,
            'line_total' => number_format((float) $this->unit_price * (int) $this->quantity, 2, '.', ''),
        ];
    }
}
