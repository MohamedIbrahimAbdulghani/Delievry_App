<?php

namespace App\Modules\Restaurants\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Restaurants\Models\Restaurant */
class RestaurantResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'city' => $this->city,
            'address' => $this->address,
            'phone' => $this->phone,
            'delivery_fee' => (string) $this->delivery_fee,
            'is_active' => (bool) $this->is_active,
            'image_url' => $this->image_url,
            'is_favorite' => auth('sanctum')->user() ? \App\Models\Favorite::where('user_id', auth('sanctum')->user()->id)->where('restaurant_id', $this->id)->exists() : false,
            'products' => \App\Modules\Products\Http\Resources\ProductResource::collection($this->whenLoaded('products')),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
