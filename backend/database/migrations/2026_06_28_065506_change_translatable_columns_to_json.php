<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Convert existing data to JSON before altering column type
        $restaurants = DB::table('restaurants')->get();
        foreach ($restaurants as $restaurant) {
            $nameJson = json_encode(['en' => $restaurant->name, 'ar' => $restaurant->name], JSON_UNESCAPED_UNICODE);
            DB::table('restaurants')->where('id', $restaurant->id)->update(['name' => $nameJson]);
        }

        $products = DB::table('products')->get();
        foreach ($products as $product) {
            $nameJson = json_encode(['en' => $product->name, 'ar' => $product->name], JSON_UNESCAPED_UNICODE);
            $descJson = json_encode(['en' => $product->description ?? '', 'ar' => $product->description ?? ''], JSON_UNESCAPED_UNICODE);
            DB::table('products')->where('id', $product->id)->update(['name' => $nameJson, 'description' => $descJson]);
        }
        
        $categories = DB::table('products')->select('category')->distinct()->get();
        foreach ($categories as $cat) {
            if ($cat->category) {
                // If it's already JSON skip
                if (strpos($cat->category, '{') === 0) continue;
                $catJson = json_encode(['en' => $cat->category, 'ar' => $cat->category], JSON_UNESCAPED_UNICODE);
                DB::table('products')->where('category', $cat->category)->update(['category' => $catJson]);
            }
        }

        Schema::table('restaurants', function (Blueprint $table) {
            $table->json('name')->change();
        });

        Schema::table('products', function (Blueprint $table) {
            $table->json('name')->change();
            $table->json('description')->nullable()->change();
            $table->json('category')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('restaurants', function (Blueprint $table) {
            $table->string('name')->change();
        });

        Schema::table('products', function (Blueprint $table) {
            $table->string('name')->change();
            $table->text('description')->nullable()->change();
            $table->string('category')->nullable()->change();
        });
    }
};
