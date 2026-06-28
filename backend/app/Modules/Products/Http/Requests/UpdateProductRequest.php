<?php

namespace App\Modules\Products\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductRequest extends FormRequest
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
        $product = $this->route('product');
        $restaurantId = $this->input('restaurant_id', $product instanceof \App\Modules\Products\Models\Product ? $product->restaurant_id : null);

        return [
            'restaurant_id' => ['sometimes', 'exists:restaurants,id'],
            'name' => ['sometimes', 'array'],
            'name.en' => ['required_with:name', 'string', 'max:255'],
            'name.ar' => ['required_with:name', 'string', 'max:255'],
            'slug' => [
                'sometimes',
                'string',
                'max:255',
                Rule::unique('products', 'slug')
                    ->ignore($product instanceof \App\Modules\Products\Models\Product ? $product->id : null)
                    ->where(fn ($q) => $q->where('restaurant_id', $restaurantId)),
            ],
            'description' => ['sometimes', 'array'],
            'description.en' => ['required_with:description', 'string'],
            'description.ar' => ['required_with:description', 'string'],
            'price' => ['sometimes', 'numeric', 'min:0'],
            'category' => ['nullable', 'array'],
            'category.en' => ['nullable', 'string', 'max:255'],
            'category.ar' => ['nullable', 'string', 'max:255'],
            'is_available' => ['nullable', 'boolean'],
            'image_url' => ['nullable', 'string', 'max:2048'],
        ];
    }
}
