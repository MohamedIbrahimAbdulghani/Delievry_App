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
            'name' => ['sometimes', 'string', 'max:255'],
            'slug' => ['sometimes', 'string', 'max:255', Rule::unique('restaurants', 'slug')->ignore($id)],
            'city' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:500'],
            'phone' => ['nullable', 'string', 'max:50'],
            'delivery_fee' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
            'image_url' => ['nullable', 'string', 'max:2048'],
        ];
    }
}
