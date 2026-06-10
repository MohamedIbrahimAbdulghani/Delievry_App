<?php

namespace App\Modules\Restaurants\Models;

use App\Modules\Orders\Models\Order;
use App\Modules\Products\Models\Product;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Restaurant extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'city',
        'address',
        'phone',
        'delivery_fee',
        'is_active',
        'image_url',
    ];

    protected function casts(): array
    {
        return [
            'delivery_fee' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}
