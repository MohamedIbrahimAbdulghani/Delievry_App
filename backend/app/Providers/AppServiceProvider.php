<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        \Illuminate\Support\Facades\Gate::policy(\App\Models\User::class, \App\Policies\UserPolicy::class);
        \Illuminate\Support\Facades\Gate::policy(\App\Modules\Restaurants\Models\Restaurant::class, \App\Policies\RestaurantPolicy::class);
        \Illuminate\Support\Facades\Gate::policy(\App\Modules\Products\Models\Product::class, \App\Policies\ProductPolicy::class);
        \Illuminate\Support\Facades\Gate::policy(\App\Modules\Orders\Models\Order::class, \App\Policies\OrderPolicy::class);
    }
}
