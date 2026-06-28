<?php

namespace App\Modules\Products\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreProductRequest extends FormRequest
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
            'restaurant_id' => ['required', 'exists:restaurants,id'],
            'name' => ['required', 'array'],
            'name.en' => ['required', 'string', 'max:255'],
            'name.ar' => ['required', 'string', 'max:255'],
            'slug' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('products', 'slug')->where(fn ($q) => $q->where('restaurant_id', $this->input('restaurant_id'))),
            ],
            'description' => ['nullable', 'array'],
            'description.en' => ['required_with:description', 'string'],
            'description.ar' => ['required_with:description', 'string'],
            'price' => ['required', 'numeric', 'min:0'],
            'category' => ['nullable', 'array'],
            'category.en' => ['nullable', 'string', 'max:255'],
            'category.ar' => ['nullable', 'string', 'max:255'],
            'is_available' => ['nullable', 'boolean'],
            'image_url' => ['nullable', 'string', 'max:2048'],
        ];
    }
}
