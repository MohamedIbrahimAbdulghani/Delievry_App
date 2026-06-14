<?php

namespace App\Policies;

use App\Models\User;
use App\Modules\Orders\Models\Order;

class OrderPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, Order $order): bool
    {
        return $user->isAdmin() || $order->user_id === $user->id || $order->driver_id === $user->id;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function accept(User $user, Order $order): bool
    {
        return ($user->isDelivery() || $user->role === 'driver') && $order->driver_id === null;
    }

    public function updateStatus(User $user, Order $order): bool
    {
        return $user->isAdmin() || $order->driver_id === $user->id;
    }

    public function managePayments(User $user, Order $order): bool
    {
        return $user->is_admin || $order->user_id === $user->id;
    }
}
