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
