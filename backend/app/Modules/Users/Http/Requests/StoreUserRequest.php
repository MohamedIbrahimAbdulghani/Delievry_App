<?php

namespace App\Modules\Users\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'is_admin' => ['sometimes', 'boolean'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:255'],
            'role' => ['sometimes', 'string', 'in:customer,delivery,admin'],
            'is_blocked' => ['sometimes', 'boolean'],
        ];
    }
}
