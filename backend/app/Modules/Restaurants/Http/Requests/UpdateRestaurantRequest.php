<?php

namespace App\Modules\Restaurants\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateRestaurantRequest extends FormRequest
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
        $restaurant = $this->route('restaurant');
        $id = $restaurant instanceof \App\Modules\Restaurants\Models\Restaurant ? $restaurant->id : $restaurant;

        return [
            'name' => ['sometimes', 'array'],
            'name.en' => ['required_with:name', 'string', 'max:255'],
            'name.ar' => ['required_with:name', 'string', 'max:255'],
            'slug' => ['sometimes', 'string', 'max:255', Rule::unique('restaurants', 'slug')->ignore($id)],
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
