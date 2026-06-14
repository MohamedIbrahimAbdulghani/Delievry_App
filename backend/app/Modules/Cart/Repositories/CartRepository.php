<?php

namespace App\Modules\Cart\Repositories;

use App\Models\User;
use App\Modules\Cart\Models\Cart;
use App\Modules\Cart\Models\CartItem;

class CartRepository
{
    public function getOrCreateForUser(User $user): Cart
    {
        return Cart::query()->firstOrCreate(['user_id' => $user->id]);
    }

    public function loadWithItems(Cart $cart): Cart
    {
        return $cart->load([
            'items' => function ($q) {
                $q->whereHas('product', function ($pq) {
                    $pq->where('is_available', true)
                        ->whereHas('restaurant', function ($rq) {
                            $rq->where('is_active', true);
                        });
                });
            },
            'items.product.restaurant'
        ]);
    }

    public function findItem(Cart $cart, int $lineId): ?CartItem
    {
        return CartItem::query()
            ->where('cart_id', $cart->id)
            ->whereKey($lineId)
            ->first();
    }
}
