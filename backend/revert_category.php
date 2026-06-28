<?php

require 'vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

$products = DB::table('products')->get();

foreach ($products as $product) {
    if (empty($product->category)) continue;

    $categoryData = json_decode($product->category, true);

    // If it was already a string, or json decode failed
    if (json_last_error() !== JSON_ERROR_NONE || !is_array($categoryData)) {
        continue;
    }

    // Extract English value, fallback to whatever is there
    $englishCategory = $categoryData['en'] ?? (is_string($categoryData) ? $categoryData : 'Meals');

    DB::table('products')->where('id', $product->id)->update([
        'category' => $englishCategory
    ]);
}

echo "Done reverting category column in products table.";
