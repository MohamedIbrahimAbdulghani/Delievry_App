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
            'phone' => '+1098765432',
            'password' => 'password',
            'is_admin' => false,
            'role' => 'customer',
        ]);

        $driver = User::query()->create([
            'name' => 'Driver Captain',
            'email' => 'driver@driver.com',
            'phone' => '+1234567890',
            'password' => 'password',
            'is_admin' => false,
            'role' => 'delivery',
            'is_online' => true,
        ]);

        $r1 = Restaurant::query()->create([
            'name' => ['en' => 'Meshwar Broast House', 'ar' => 'مشوار بروست هاوس'],
            'slug' => 'meshwar-broast-house',
            'city' => ['en' => 'Demo City', 'ar' => 'مدينة ديمو'],
            'address' => ['en' => '123 Main Street', 'ar' => '١٢٣ شارع رئيسي'],
            'phone' => '+1000000000',
            'delivery_fee' => 2.50,
            'is_active' => true,
            'image_url' => 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r1->id,
            'name' => ['en' => 'Classic Broast', 'ar' => 'بروست كلاسيك'],
            'slug' => 'classic-broast',
            'description' => ['en' => 'Crispy fried broast chicken meal served with garlic sauce and fries.', 'ar' => 'وجبة دجاج بروست مقرمش تقدم مع صوص الثوم والبطاطس المقلية.'],
            'price' => 12.99,
            'category' => ['en' => 'Broast', 'ar' => 'بروست'],
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1562967914-608f82629710?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r1->id,
            'name' => ['en' => 'Family Bucket', 'ar' => 'باقة العائلة'],
            'slug' => 'family-bucket',
            'description' => ['en' => '12 pieces of crispy broast chicken, large fries, and family garlic sauce.', 'ar' => '12 قطعة دجاج بروست مقرمش، بطاطس كبيرة، وصوص ثوم عائلي.'],
            'price' => 34.50,
            'category' => ['en' => 'Buckets', 'ar' => 'باقات'],
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r1->id,
            'name' => ['en' => 'Spicy Chicken Tenders', 'ar' => 'ستربس دجاج حار'],
            'slug' => 'spicy-tenders',
            'description' => ['en' => '6 pieces of spicy boneless chicken tenders with dipping sauce.', 'ar' => '6 قطع ستربس دجاج بدون عظم مع صوص للتغميس.'],
            'price' => 9.99,
            'category' => ['en' => 'Tenders', 'ar' => 'ستربس'],
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=600&auto=format&fit=crop',
        ]);

        $r2 = Restaurant::query()->create([
            'name' => ['en' => 'Bella Italia', 'ar' => 'بيلا إيطاليا'],
            'slug' => 'bella-italia',
            'city' => ['en' => 'Demo City', 'ar' => 'مدينة ديمو'],
            'address' => ['en' => '456 Olive Avenue', 'ar' => '٤٥٦ شارع الزيتون'],
            'phone' => '+1000000001',
            'delivery_fee' => 3.00,
            'is_active' => true,
            'image_url' => 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r2->id,
            'name' => ['en' => 'Margherita Pizza', 'ar' => 'بيتزا مارجريتا'],
            'slug' => 'margherita-pizza',
            'description' => ['en' => 'Classic Italian pizza with tomato sauce, fresh mozzarella, and basil.', 'ar' => 'بيتزا إيطالية كلاسيكية مع صلصة الطماطم، جبن الموزاريلا الطازج، والريحان.'],
            'price' => 10.99,
            'category' => ['en' => 'Pizza', 'ar' => 'بيتزا'],
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r2->id,
            'name' => ['en' => 'Fettuccine Carbonara', 'ar' => 'فيتوتشيني كاربونارا'],
            'slug' => 'fettuccine-carbonara',
            'description' => ['en' => 'Rich creamy pasta with parmesan cheese, egg yolk, and beef bacon.', 'ar' => 'مكرونة كريمية غنية بجبنة البارميزان وصفار البيض ولحم البقر المقدد.'],
            'price' => 14.50,
            'category' => ['en' => 'Pasta', 'ar' => 'مكرونة'],
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=600&auto=format&fit=crop',
        ]);

        $r3 = Restaurant::query()->create([
            'name' => ['en' => 'Burger Craft', 'ar' => 'برجر كرافت'],
            'slug' => 'burger-craft',
            'city' => ['en' => 'Demo City', 'ar' => 'مدينة ديمو'],
            'address' => ['en' => '789 Smokehouse Way', 'ar' => '٧٨٩ ممر بيت الدخان'],
            'phone' => '+1000000002',
            'delivery_fee' => 1.99,
            'is_active' => true,
            'image_url' => 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r3->id,
            'name' => ['en' => 'Double Cheese Burger', 'ar' => 'دبل تشيز برجر'],
            'slug' => 'double-cheese-burger',
            'description' => ['en' => 'Two flame-grilled beef patties, cheddar cheese, special sauce, lettuce, and pickles.', 'ar' => 'شريحتين لحم بقري مشوي على اللهب، جبنة الشيدر، صوص خاص، خس، ومخلل.'],
            'price' => 8.99,
            'category' => ['en' => 'Burgers', 'ar' => 'برجر'],
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop',
        ]);

        Product::query()->create([
            'restaurant_id' => $r3->id,
            'name' => ['en' => 'Crispy Truffle Fries', 'ar' => 'بطاطس ترافل مقرمشة'],
            'slug' => 'truffle-fries',
            'description' => ['en' => 'Golden French fries tossed in white truffle oil and parmesan cheese.', 'ar' => 'بطاطس مقلية ذهبية ممزوجة بزيت الترافل الأبيض وجبنة البارميزان.'],
            'price' => 4.50,
            'category' => ['en' => 'Sides', 'ar' => 'أطباق جانبية'],
            'is_available' => true,
            'image_url' => 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&auto=format&fit=crop',
        ]);

        $this->command?->info('Seeded users: Admin: admin@admin.com (admin123) | Customer: customer@broastmeshwar.test (password) | Driver: driver@driver.com (password)');
        $this->command?->info('Admin ID: '.$admin->id.' Customer ID: '.$customer->id.' Driver ID: '.$driver->id);
    }
}
