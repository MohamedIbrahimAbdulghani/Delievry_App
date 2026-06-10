<?php

namespace App\Modules\Orders\Http\Resources;

use App\Modules\Payments\Http\Resources\PaymentResource;
use App\Modules\Restaurants\Http\Resources\RestaurantResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Orders\Models\Order */
class OrderResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'restaurant_id' => $this->restaurant_id,
            'status' => $this->status,
            'delivery_address' => $this->delivery_address,
            'notes' => $this->notes,
            'subtotal' => (string) $this->subtotal,
            'delivery_fee' => (string) $this->delivery_fee,
            'total' => (string) $this->total,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'placed_at' => $this->placed_at?->toIso8601String(),
            'restaurant' => $this->whenLoaded('restaurant', fn () => new RestaurantResource($this->restaurant)),
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'payments' => PaymentResource::collection($this->whenLoaded('payments')),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
