<?php

namespace Database\Seeders;

use App\Models\User;
use App\Modules\Products\Models\Product;
use App\Modules\Restaurants\Models\Restaurant;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $admin = User::query()->create([
            'name' => 'Admin',
            'email' => 'admin@admin.com',
            'password' => 'admin123',
            'is_admin' => true,
        ]);

        $customer = User::query()->create([
            'name' => 'Customer',
            'email' => 'customer@broastmeshwar.test',
            'password' => 'password',
            'is_admin' => false,
            'role' => 'customer',
        ]);

        $driver = User::query()->create([
            'name' => 'Driver Captain',
            'email' => 'driver@driver.com',
            'password' => 'password',
            'is_admin' => false,
            'role' => 'delivery',
            'is_online' => true,
        ]);

        $r1 = Restaurant::query()->create([
            'name' => 'Meshwar Broast House',
            'slug' => 'meshwar-broast-house',
            'city' => 'Demo City',
            'address' => '123 Main Street',
            'phone' => '+1000000000',
            'delivery_fee' => 2.50,
            'is_active' => true,
            'image_url' => 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r1->id,
            'name' => 'Classic Broast',
            'slug' => 'classic-broast',
            'description' => 'Crispy fried broast chicken meal served with garlic sauce and fries.',
            'price' => 12.99,
            'category' => 'Broast',
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1562967914-608f82629710?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r1->id,
            'name' => 'Family Bucket',
            'slug' => 'family-bucket',
            'description' => '12 pieces of crispy broast chicken, large fries, and family garlic sauce.',
            'price' => 34.50,
            'category' => 'Buckets',
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r1->id,
            'name' => 'Spicy Chicken Tenders',
            'slug' => 'spicy-tenders',
            'description' => '6 pieces of spicy boneless chicken tenders with dipping sauce.',
            'price' => 9.99,
            'category' => 'Tenders',
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=600&auto=format&fit=crop',
        ]);

        $r2 = Restaurant::query()->create([
            'name' => 'Bella Italia',
            'slug' => 'bella-italia',
            'city' => 'Demo City',
            'address' => '456 Olive Avenue',
            'phone' => '+1000000001',
            'delivery_fee' => 3.00,
            'is_active' => true,
            'image_url' => 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r2->id,
            'name' => 'Margherita Pizza',
            'slug' => 'margherita-pizza',
            'description' => 'Classic Italian pizza with tomato sauce, fresh mozzarella, and basil.',
            'price' => 10.99,
            'category' => 'Pizza',
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r2->id,
            'name' => 'Fettuccine Carbonara',
            'slug' => 'fettuccine-carbonara',
            'description' => 'Rich creamy pasta with parmesan cheese, egg yolk, and beef bacon.',
            'price' => 14.50,
            'category' => 'Pasta',
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=600&auto=format&fit=crop',
        ]);

        $r3 = Restaurant::query()->create([
            'name' => 'Burger Craft',
            'slug' => 'burger-craft',
            'city' => 'Demo City',
            'address' => '789 Smokehouse Way',
            'phone' => '+1000000002',
            'delivery_fee' => 1.99,
            'is_active' => true,
            'image_url' => 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r3->id,
            'name' => 'Double Cheese Burger',
            'slug' => 'double-cheese-burger',
            'description' => 'Two flame-grilled beef patties, cheddar cheese, special sauce, lettuce, and pickles.',
            'price' => 8.99,
            'category' => 'Burgers',
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r3->id,
            'name' => 'Crispy Truffle Fries',
            'slug' => 'truffle-fries',
            'description' => 'Golden French fries tossed in white truffle oil and parmesan cheese.',
            'price' => 4.50,
            'category' => 'Sides',
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&auto=format&fit=crop',
        ]);

        $this->command?->info('Seeded users: Admin: admin@admin.com (admin123) | Customer: customer@broastmeshwar.test (password) | Driver: driver@driver.com (password)');
        $this->command?->info('Admin ID: '.$admin->id.' Customer ID: '.$customer->id.' Driver ID: '.$driver->id);
    }
}
