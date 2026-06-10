<?php

namespace App\Modules\Products\Http\Resources;

use App\Modules\Restaurants\Http\Resources\RestaurantResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Modules\Products\Models\Product */
class ProductResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'restaurant_id' => $this->restaurant_id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'price' => (string) $this->price,
            'category' => $this->category,
            'is_available' => (bool) $this->is_available,
            'image_url' => $this->image_url,
            'restaurant' => $this->whenLoaded('restaurant', fn () => new RestaurantResource($this->restaurant)),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
