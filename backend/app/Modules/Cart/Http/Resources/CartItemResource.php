<?php

namespace App\Modules\Cart\Http\Resources;

use App\Modules\Products\Http\Resources\ProductResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Cart\Models\CartItem */
class CartItemResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'quantity' => (int) $this->quantity,
            'options' => $this->options,
            'line_total' => $this->when(
                $this->relationLoaded('product') && $this->product,
                fn () => number_format((float) $this->product->price * (int) $this->quantity, 2, '.', '')
            ),
            'product' => $this->whenLoaded('product', fn () => new ProductResource($this->product)),
        ];
    }
}
