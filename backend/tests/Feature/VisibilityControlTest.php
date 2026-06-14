<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Favorite;
use App\Modules\Products\Models\Product;
use App\Modules\Restaurants\Models\Restaurant;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VisibilityControlTest extends TestCase
{
    use RefreshDatabase;

    protected User $admin;
    protected User $customer;
    protected Restaurant $activeRestaurant;
    protected Restaurant $inactiveRestaurant;
    protected Product $availableProductOfActive;
    protected Product $unavailableProductOfActive;
    protected Product $productOfInactive;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::query()->create([
            'name' => 'Admin User',
            'email' => 'admin@test.com',
            'password' => bcrypt('password'),
            'is_admin' => true,
        ]);

        $this->customer = User::query()->create([
            'name' => 'Customer User',
            'email' => 'customer@test.com',
            'password' => bcrypt('password'),
            'is_admin' => false,
            'role' => 'customer',
        ]);

        $this->activeRestaurant = Restaurant::query()->create([
            'name' => 'Active Diner',
            'slug' => 'active-diner',
            'city' => 'New York',
            'address' => '123 active rd',
            'phone' => '123456789',
            'delivery_fee' => 1.50,
            'is_active' => true,
        ]);

        $this->inactiveRestaurant = Restaurant::query()->create([
            'name' => 'Inactive Diner',
            'slug' => 'inactive-diner',
            'city' => 'New York',
            'address' => '456 inactive rd',
            'phone' => '987654321',
            'delivery_fee' => 2.50,
            'is_active' => false,
        ]);

        $this->availableProductOfActive = Product::query()->create([
            'restaurant_id' => $this->activeRestaurant->id,
            'name' => 'Available Burger',
            'slug' => 'available-burger',
            'description' => 'Tastes great',
            'price' => 10.00,
            'category' => 'Burgers',
            'is_available' => true,
        ]);

        $this->unavailableProductOfActive = Product::query()->create([
            'restaurant_id' => $this->activeRestaurant->id,
            'name' => 'Unavailable Burger',
            'slug' => 'unavailable-burger',
            'description' => 'Out of stock',
            'price' => 8.00,
            'category' => 'Burgers',
            'is_available' => false,
        ]);

        $this->productOfInactive = Product::query()->create([
            'restaurant_id' => $this->inactiveRestaurant->id,
            'name' => 'Inactive Diner Pizza',
            'slug' => 'inactive-diner-pizza',
            'description' => 'From closed restaurant',
            'price' => 12.00,
            'category' => 'Pizza',
            'is_available' => true,
        ]);
    }

    public function test_customer_can_only_list_active_restaurants(): void
    {
        // 1. As Guest / Customer
        $response = $this->getJson('/api/v1/restaurants');
        $response->assertStatus(200);
        $data = $response->json('data.items');
        
        $names = collect($data)->pluck('name');
        $this->assertTrue($names->contains('Active Diner'));
        $this->assertFalse($names->contains('Inactive Diner'));

        // 2. As Admin
        $response = $this->actingAs($this->admin, 'sanctum')->getJson('/api/v1/restaurants');
        $response->assertStatus(200);
        $data = $response->json('data.items');
        
        $names = collect($data)->pluck('name');
        $this->assertTrue($names->contains('Active Diner'));
        $this->assertTrue($names->contains('Inactive Diner'));
    }

    public function test_customer_cannot_view_inactive_restaurant_details(): void
    {
        // Guest/Customer viewing active restaurant
        $response = $this->getJson('/api/v1/restaurants/' . $this->activeRestaurant->id);
        $response->assertStatus(200);

        // Guest/Customer viewing inactive restaurant -> 403
        $response = $this->getJson('/api/v1/restaurants/' . $this->inactiveRestaurant->id);
        $response->assertStatus(403);

        // Admin viewing inactive restaurant -> 200
        $response = $this->actingAs($this->admin, 'sanctum')->getJson('/api/v1/restaurants/' . $this->inactiveRestaurant->id);
        $response->assertStatus(200);
    }

    public function test_customer_can_only_list_available_products_of_active_restaurants(): void
    {
        // 1. As Guest / Customer
        $response = $this->getJson('/api/v1/products');
        $response->assertStatus(200);
        $data = $response->json('data.items');

        $names = collect($data)->pluck('name');
        $this->assertTrue($names->contains('Available Burger'));
        $this->assertFalse($names->contains('Unavailable Burger'));
        $this->assertFalse($names->contains('Inactive Diner Pizza'));

        // 2. As Admin
        $response = $this->actingAs($this->admin, 'sanctum')->getJson('/api/v1/products');
        $response->assertStatus(200);
        $data = $response->json('data.items');

        $names = collect($data)->pluck('name');
        $this->assertTrue($names->contains('Available Burger'));
        $this->assertTrue($names->contains('Unavailable Burger'));
        $this->assertTrue($names->contains('Inactive Diner Pizza'));
    }

    public function test_customer_cannot_view_unavailable_or_inactive_restaurant_product_details(): void
    {
        // Guest/Customer viewing active/available product
        $response = $this->getJson('/api/v1/products/' . $this->availableProductOfActive->id);
        $response->assertStatus(200);

        // Guest/Customer viewing unavailable product -> 403
        $response = $this->getJson('/api/v1/products/' . $this->unavailableProductOfActive->id);
        $response->assertStatus(403);

        // Guest/Customer viewing active product of inactive restaurant -> 403
        $response = $this->getJson('/api/v1/products/' . $this->productOfInactive->id);
        $response->assertStatus(403);

        // Admin viewing unavailable product -> 200
        $response = $this->actingAs($this->admin, 'sanctum')->getJson('/api/v1/products/' . $this->unavailableProductOfActive->id);
        $response->assertStatus(200);

        // Admin viewing inactive restaurant's product -> 200
        $response = $this->actingAs($this->admin, 'sanctum')->getJson('/api/v1/products/' . $this->productOfInactive->id);
        $response->assertStatus(200);
    }

    public function test_customer_favorites_excludes_inactive_restaurants(): void
    {
        Favorite::query()->create([
            'user_id' => $this->customer->id,
            'restaurant_id' => $this->activeRestaurant->id,
        ]);

        Favorite::query()->create([
            'user_id' => $this->customer->id,
            'restaurant_id' => $this->inactiveRestaurant->id,
        ]);

        // Fetch favorites as customer
        $response = $this->actingAs($this->customer, 'sanctum')->getJson('/api/v1/favorites');
        $response->assertStatus(200);
        
        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals($this->activeRestaurant->id, $data[0]['restaurant']['id']);
    }

    public function test_customer_cannot_add_unavailable_or_inactive_restaurant_product_to_cart(): void
    {
        // 1. Trying to add unavailable product
        $response = $this->actingAs($this->customer, 'sanctum')->postJson('/api/v1/cart/items', [
            'product_id' => $this->unavailableProductOfActive->id,
            'quantity' => 1,
        ]);
        $response->assertStatus(422);
        $response->assertJsonValidationErrors('product_id');

        // 2. Trying to add product of inactive restaurant
        $response = $this->actingAs($this->customer, 'sanctum')->postJson('/api/v1/cart/items', [
            'product_id' => $this->productOfInactive->id,
            'quantity' => 1,
        ]);
        $response->assertStatus(422);
        $response->assertJsonValidationErrors('product_id');

        // 3. Adding valid product -> 200
        $response = $this->actingAs($this->customer, 'sanctum')->postJson('/api/v1/cart/items', [
            'product_id' => $this->availableProductOfActive->id,
            'quantity' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_cart_filters_out_unavailable_or_inactive_items_on_retrieval(): void
    {
        // Logged-in customer cart
        $this->actingAs($this->customer, 'sanctum')->postJson('/api/v1/cart/items', [
            'product_id' => $this->availableProductOfActive->id,
            'quantity' => 2,
        ])->assertStatus(200);

        // Now, mock addition of unavailable item by directly inserting into database (bypassing controller check)
        $cart = \App\Modules\Cart\Models\Cart::query()->firstOrCreate(['user_id' => $this->customer->id]);
        
        // Add unavailable product to cart via DB
        $cart->items()->create([
            'product_id' => $this->unavailableProductOfActive->id,
            'quantity' => 1,
        ]);

        // Add inactive restaurant product to cart via DB
        $cart->items()->create([
            'product_id' => $this->productOfInactive->id,
            'quantity' => 3,
        ]);

        // Retrieve cart via API
        $response = $this->actingAs($this->customer, 'sanctum')->getJson('/api/v1/cart');
        $response->assertStatus(200);
        
        $data = $response->json('data');
        
        // Should only return 1 item (the active available burger)
        $this->assertCount(1, $data['items']);
        $this->assertEquals($this->availableProductOfActive->id, $data['items'][0]['product']['id']);
        
        // Subtotal should only include the available burger: 10.00 * 2 = 20.00
        $this->assertEquals('20.00', $data['subtotal']);
    }
}
