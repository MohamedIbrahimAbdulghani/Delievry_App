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
            'name_en' => $this->getTranslation('name', 'en', false),
            'name_ar' => $this->getTranslation('name', 'ar', false),
            'name' => $this->name, // keep original for backwards compatibility or fallback
            'slug' => $this->slug,
            'city_en' => $this->getTranslation('city', 'en', false),
            'city_ar' => $this->getTranslation('city', 'ar', false),
            'city' => $this->city,
            'address_en' => $this->getTranslation('address', 'en', false),
            'address_ar' => $this->getTranslation('address', 'ar', false),
            'address' => $this->address,
            'phone' => $this->phone,
            'delivery_fee' => (string) $this->delivery_fee,
            'is_active' => (bool) $this->is_active,
            'image_url' => $this->image_url,
            'is_favorite' => auth('sanctum')->user() ? \App\Models\Favorite::where('user_id', auth('sanctum')->user()->id)->where('restaurant_id', $this->id)->exists() : false,
            'products' => \App\Modules\Products\Http\Resources\ProductResource::collection($this->whenLoaded('products')),
            'reviews' => ReviewResource::collection($this->whenLoaded('reviews')),
            'rating' => (double) ($this->reviews()->avg('rating') ?? 0.0),
            'total_reviews' => (int) $this->reviews()->count(),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
