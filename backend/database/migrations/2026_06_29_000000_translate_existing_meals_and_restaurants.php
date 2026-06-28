<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use App\Modules\Restaurants\Models\Restaurant;
use App\Modules\Products\Models\Product;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $restaurants = [
            1 => [
                'name' => ['en' => 'Meshwar Broast House', 'ar' => 'مشوار بروست هاوس'],
                'city' => ['en' => 'Demo City', 'ar' => 'مدينة ديمو'],
                'address' => ['en' => '123 Main Street', 'ar' => '١٢٣ شارع رئيسي'],
            ],
            2 => [
                'name' => ['en' => 'Bella Italia', 'ar' => 'بيلا إيطاليا'],
                'city' => ['en' => 'Demo City', 'ar' => 'مدينة ديمو'],
                'address' => ['en' => '456 Olive Avenue', 'ar' => '٤٥٦ شارع الزيتون'],
            ],
            3 => [
                'name' => ['en' => 'Burger Craft', 'ar' => 'برجر كرافت'],
                'city' => ['en' => 'Demo City', 'ar' => 'مدينة ديمو'],
                'address' => ['en' => '789 Smokehouse Way', 'ar' => '٧٨٩ ممر بيت الدخان'],
            ],
            4 => [
                'name' => ['en' => 'Shajarat Al-Durr', 'ar' => 'شجرة الدر'],
                'city' => ['en' => 'Cairo', 'ar' => 'القاهرة'],
                'address' => ['en' => 'El-Moez Street', 'ar' => 'شارع المعز'],
            ],
        ];

        foreach ($restaurants as $id => $data) {
            $r = Restaurant::find($id);
            if ($r) {
                $r->setTranslations('name', $data['name']);
                $r->setTranslations('city', $data['city']);
                $r->setTranslations('address', $data['address']);
                $r->save();
            }
        }

        $products = [
            1 => [
                'name' => ['en' => 'Classic Broast', 'ar' => 'بروست كلاسيك'],
                'desc' => ['en' => 'Crispy fried broast chicken meal served with garlic sauce and fries.', 'ar' => 'وجبة دجاج بروست مقرمش تقدم مع صوص الثوم والبطاطس المقلية.'],
                'cat' => ['en' => 'Broast', 'ar' => 'بروست']
            ],
            2 => [
                'name' => ['en' => 'Family Bucket', 'ar' => 'باقة العائلة'],
                'desc' => ['en' => '12 pieces of crispy broast chicken, large fries, and family garlic sauce.', 'ar' => '12 قطعة دجاج بروست مقرمش، بطاطس كبيرة، وصوص ثوم عائلي.'],
                'cat' => ['en' => 'Buckets', 'ar' => 'باقات']
            ],
            3 => [
                'name' => ['en' => 'Spicy Chicken Tenders', 'ar' => 'ستربس دجاج حار'],
                'desc' => ['en' => '6 pieces of spicy boneless chicken tenders with dipping sauce.', 'ar' => '6 قطع ستربس دجاج بدون عظم مع صوص للتغميس.'],
                'cat' => ['en' => 'Tenders', 'ar' => 'ستربس']
            ],
            4 => [
                'name' => ['en' => 'Margherita Pizza', 'ar' => 'بيتزا مارجريتا'],
                'desc' => ['en' => 'Classic Italian pizza with tomato sauce, fresh mozzarella, and basil.', 'ar' => 'بيتزا إيطالية كلاسيكية مع صلصة الطماطم، جبن الموزاريلا الطازج، والريحان.'],
                'cat' => ['en' => 'Pizza', 'ar' => 'بيتزا']
            ],
            5 => [
                'name' => ['en' => 'Fettuccine Carbonara', 'ar' => 'فيتوتشيني كاربونارا'],
                'desc' => ['en' => 'Rich creamy pasta with parmesan cheese, egg yolk, and beef bacon.', 'ar' => 'مكرونة كريمية غنية بجبنة البارميزان وصفار البيض ولحم البقر المقدد.'],
                'cat' => ['en' => 'Pasta', 'ar' => 'مكرونة']
            ],
            6 => [
                'name' => ['en' => 'Double Cheese Burger', 'ar' => 'دبل تشيز برجر'],
                'desc' => ['en' => 'Two flame-grilled beef patties, cheddar cheese, special sauce, lettuce, and pickles.', 'ar' => 'شريحتين لحم بقري مشوي على اللهب، جبنة الشيدر، صوص خاص، خس، ومخلل.'],
                'cat' => ['en' => 'Burgers', 'ar' => 'برجر']
            ],
            7 => [
                'name' => ['en' => 'Crispy Truffle Fries', 'ar' => 'بطاطس ترافل مقرمشة'],
                'desc' => ['en' => 'Golden French fries tossed in white truffle oil and parmesan cheese.', 'ar' => 'بطاطس مقلية ذهبية ممزوجة بزيت الترافل الأبيض وجبنة البارميزان.'],
                'cat' => ['en' => 'Sides', 'ar' => 'أطباق جانبية']
            ],
            8 => [
                'name' => ['en' => 'Meat Paper (Waraqet Lahma)', 'ar' => 'ورقة لحمة'],
                'desc' => ['en' => 'Tender beef pieces cooked in parchment paper, with potatoes, carrots, peppers and onions, seasoned with herbs and spices.', 'ar' => 'قطع لحم العجل الطرية المطبوخة في ورق البرشمان، مع البطاطس والجزر والفلفل والبصل، متبلة بالأعشاب والتوابل.'],
                'cat' => ['en' => 'Meals', 'ar' => 'وجبات']
            ],
            9 => [
                'name' => ['en' => 'Pigeon stuffed with Freekeh', 'ar' => 'حمام محشي فريك'],
                'desc' => ['en' => 'Pigeon stuffed with freekeh, onions, ghee and Egyptian spices. Fried until golden and crispy.', 'ar' => 'حمامة محشي فريك والبصل والسمن والتوابل المصرية. مقلية حتى تصبح قشرتها ذهبية ومقرمشة.'],
                'cat' => ['en' => 'Meals', 'ar' => 'وجبات']
            ],
        ];

        foreach ($products as $id => $data) {
            $p = Product::find($id);
            if ($p) {
                $p->setTranslations('name', $data['name']);
                $p->setTranslations('description', $data['desc']);
                $p->setTranslations('category', $data['cat']);
                $p->save();
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert is not strictly necessary for this data correction migration
    }
};
