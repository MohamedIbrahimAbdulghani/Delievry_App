<?php

namespace App\Modules\Users\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\User */
class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'is_admin' => (bool) $this->is_admin,
            'role' => $this->role ?? 'customer',
            'is_online' => (bool) $this->is_online,
            'is_blocked' => (bool) $this->is_blocked,
            'latitude' => $this->latitude ? (double) $this->latitude : null,
            'longitude' => $this->longitude ? (double) $this->longitude : null,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
