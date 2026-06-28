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
        $locale = app()->getLocale();

        $nameEn = $this->getTranslation('name', 'en', false) ?: '';
        $nameAr = $this->getTranslation('name', 'ar', false) ?: '';
        $name = $locale === 'ar' ? $nameAr : $nameEn;
        if (empty($name)) {
            $name = $locale === 'ar' ? 'اسم غير متوفر' : 'Name not available';
        }

        $descEn = $this->getTranslation('description', 'en', false) ?: '';
        $descAr = $this->getTranslation('description', 'ar', false) ?: '';
        $description = $locale === 'ar' ? $descAr : $descEn;
        if (empty($description)) {
            $description = $locale === 'ar' ? 'الوصف غير متوفر' : 'Description not available';
        }

        $catEn = $this->getTranslation('category', 'en', false) ?: '';
        $catAr = $this->getTranslation('category', 'ar', false) ?: '';
        $category = $locale === 'ar' ? $catAr : $catEn;
        if (empty($category)) {
            $category = $locale === 'ar' ? 'غير مصنف' : 'Uncategorized';
        }

        return [
            'id' => $this->id,
            'restaurant_id' => $this->restaurant_id,
            'name_en' => $nameEn,
            'name_ar' => $nameAr,
            'name' => $name,
            'slug' => $this->slug,
            'description_en' => $descEn,
            'description_ar' => $descAr,
            'description' => $description,
            'price' => (string) $this->price,
            'category_en' => $catEn,
            'category_ar' => $catAr,
            'category' => $category,
            'is_available' => (bool) $this->is_available,
            'image_url' => $this->image_url,
            'restaurant' => $this->whenLoaded('restaurant', fn () => new RestaurantResource($this->restaurant)),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
