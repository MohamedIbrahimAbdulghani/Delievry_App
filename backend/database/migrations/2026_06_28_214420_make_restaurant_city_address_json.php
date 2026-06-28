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
            $cityJson = json_encode(['en' => $restaurant->city ?? '', 'ar' => $restaurant->city ?? ''], JSON_UNESCAPED_UNICODE);
            $addressJson = json_encode(['en' => $restaurant->address ?? '', 'ar' => $restaurant->address ?? ''], JSON_UNESCAPED_UNICODE);
            DB::table('restaurants')->where('id', $restaurant->id)->update(['city' => $cityJson, 'address' => $addressJson]);
        }

        Schema::table('restaurants', function (Blueprint $table) {
            $table->json('city')->nullable()->change();
            $table->json('address')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('restaurants', function (Blueprint $table) {
            $table->string('city')->nullable()->change();
            $table->string('address')->nullable()->change();
        });
    }
};
