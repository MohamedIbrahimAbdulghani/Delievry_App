<?php

namespace App\Modules\Restaurants\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreRestaurantRequest extends FormRequest
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
            'name' => ['required', 'array'],
            'name.en' => ['required', 'string', 'max:255'],
            'name.ar' => ['required', 'string', 'max:255'],
            'slug' => ['nullable', 'string', 'max:255', 'unique:restaurants,slug'],
            'city' => ['nullable', 'array'],
            'city.en' => ['nullable', 'string', 'max:255'],
            'city.ar' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'array'],
            'address.en' => ['nullable', 'string', 'max:500'],
            'address.ar' => ['nullable', 'string', 'max:500'],
            'phone' => ['nullable', 'string', 'max:50'],
            'delivery_fee' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
            'image_url' => ['nullable', 'string', 'max:2048'],
        ];
    }
}
