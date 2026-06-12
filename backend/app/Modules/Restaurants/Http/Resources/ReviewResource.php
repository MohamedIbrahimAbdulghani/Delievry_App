<?php

namespace App\Modules\Restaurants\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReviewResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_name' => $this->user?->name ?? 'Anonymous',
            'user_image_url' => null,
            'rating' => (double) $this->rating,
            'comment' => $this->comment ?? '',
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
