<?php

namespace App\Modules\Cart\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Cart\Models\Cart */
class CartResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $subtotal = 0.0;
        if ($this->relationLoaded('items')) {
            foreach ($this->items as $item) {
                if ($item->relationLoaded('product') && $item->product) {
                    $subtotal += (float) $item->product->price * (int) $item->quantity;
                }
            }
        }

        return [
            'id' => $this->id,
            'subtotal' => number_format($subtotal, 2, '.', ''),
            'items' => CartItemResource::collection($this->whenLoaded('items')),
        ];
    }
}
