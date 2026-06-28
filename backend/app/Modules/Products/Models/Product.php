<?php

namespace App\Modules\Products\Models;

use App\Modules\Restaurants\Models\Restaurant;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Spatie\Translatable\HasTranslations;

class Product extends Model
{
    use HasTranslations;

    public $translatable = ['name', 'description', 'category'];
    protected $fillable = [
        'restaurant_id',
        'name',
        'slug',
        'description',
        'price',
        'category',
        'is_available',
        'image_url',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'is_available' => 'boolean',
        ];
    }

    public function restaurant(): BelongsTo
    {
        return $this->belongsTo(Restaurant::class);
    }
}
