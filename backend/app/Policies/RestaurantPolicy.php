<?php

namespace App\Policies;

use App\Models\User;
use App\Modules\Restaurants\Models\Restaurant;
use Illuminate\Contracts\Auth\Authenticatable;

class RestaurantPolicy
{
    public function viewAny(?Authenticatable $user): bool
    {
        return true;
    }

    public function view(?Authenticatable $user, Restaurant $restaurant): bool
    {
        return true;
    }

    public function create(User $user): bool
    {
        return $user->is_admin;
    }

    public function update(User $user, Restaurant $restaurant): bool
    {
        return $user->is_admin;
    }

    public function delete(User $user, Restaurant $restaurant): bool
    {
        return $user->is_admin;
    }
}
