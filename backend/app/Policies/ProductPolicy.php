<?php

namespace App\Policies;

use App\Models\User;
use App\Modules\Products\Models\Product;
use Illuminate\Contracts\Auth\Authenticatable;

class ProductPolicy
{
    public function viewAny(?Authenticatable $user): bool
    {
        return true;
    }

    public function view(?Authenticatable $user, Product $product): bool
    {
        $restaurant = $product->restaurant;
        $isRestaurantActive = $restaurant ? $restaurant->is_active : false;

        if (!$product->is_available || !$isRestaurantActive) {
            return $user && ($user->is_admin || $user->role === 'admin');
        }
        return true;
    }

    public function create(User $user): bool
    {
        return $user->is_admin;
    }

    public function update(User $user, Product $product): bool
    {
        return $user->is_admin;
    }

    public function delete(User $user, Product $product): bool
    {
        return $user->is_admin;
    }
}
