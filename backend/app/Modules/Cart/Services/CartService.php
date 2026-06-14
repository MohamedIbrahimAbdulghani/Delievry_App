<?php

namespace App\Modules\Cart\Services;

use App\Models\User;
use App\Modules\Cart\Http\Resources\CartResource;
use App\Modules\Cart\Models\CartItem;
use App\Modules\Cart\Repositories\CartRepository;
use App\Modules\Products\Models\Product;
use Illuminate\Validation\ValidationException;

class CartService
{
    public function __construct(
        protected CartRepository $carts,
    ) {}

    public function getCart(User $user): CartResource
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $this->carts->loadWithItems($cart);

        return new CartResource($cart);
    }

    public function addItem(User $user, int $productId, int $quantity, ?array $options): CartResource
    {
        $product = Product::query()->with('restaurant')->findOrFail($productId);
        if (! $product->is_available) {
            throw ValidationException::withMessages(['product_id' => [__('Product is not available.')]]);
        }
        if (! $product->restaurant || ! $product->restaurant->is_active) {
            throw ValidationException::withMessages(['product_id' => [__('Restaurant is currently inactive.')]]);
        }

        $cart = $this->carts->getOrCreateForUser($user);
        $options = $options ?? null;

        $existing = CartItem::query()
            ->where('cart_id', $cart->id)
            ->where('product_id', $productId)
            ->get();

        foreach ($existing as $line) {
            if ($this->optionsEqual($line->options, $options)) {
                $line->quantity += $quantity;
                $line->save();
                $this->carts->loadWithItems($cart);

                return new CartResource($cart);
            }
        }

        CartItem::query()->create([
            'cart_id' => $cart->id,
            'product_id' => $productId,
            'quantity' => $quantity,
            'options' => $options,
        ]);

        $this->carts->loadWithItems($cart);

        return new CartResource($cart);
    }

    public function updateItem(User $user, int $lineId, int $quantity, ?array $options): CartResource
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $line = $this->carts->findItem($cart, $lineId);
        if (! $line) {
            throw ValidationException::withMessages(['line' => [__('Cart line not found.')]]);
        }

        $line->quantity = $quantity;
        $line->options = $options;
        $line->save();

        $this->carts->loadWithItems($cart);

        return new CartResource($cart);
    }

    public function removeItem(User $user, int $lineId): CartResource
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $line = $this->carts->findItem($cart, $lineId);
        if ($line) {
            $line->delete();
        }
        $this->carts->loadWithItems($cart);

        return new CartResource($cart);
    }

    public function clear(User $user): CartResource
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $cart->items()->delete();
        $this->carts->loadWithItems($cart);

        return new CartResource($cart);
    }

    protected function optionsEqual(?array $a, ?array $b): bool
    {
        return json_encode($this->normalizeOptions($a)) === json_encode($this->normalizeOptions($b));
    }

    protected function normalizeOptions(?array $options): ?array
    {
        if ($options === null || $options === []) {
            return null;
        }
        ksort($options);

        return $options;
    }
}
