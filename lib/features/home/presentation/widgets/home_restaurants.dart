import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';

class HomeRestaurants extends StatelessWidget {
  final List<RestaurantEntity> restaurants;

  const HomeRestaurants({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Restaurants',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 20,
                ) ?? const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              TextButton(
                onPressed: () => context.push('/search'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'See All', 
                  style: TextStyle(
                    color: AppColors.primary, 
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  )
                ),
              ),
            ],
          ),
        ),
        restaurants.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: Text(
                    'No restaurants found.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return GestureDetector(
              onTap: () => context.push('/restaurant-details/${restaurant.id}'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: Image.network(
                            _getImageUrl(restaurant.imageUrl),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: AppColors.background,
                                child: const Center(child: Icon(Icons.restaurant, color: AppColors.outline, size: 50)),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              context.read<HomeBloc>().add(ToggleFavoriteRestaurant(restaurant.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    restaurant.isFavorite 
                                        ? 'Removed ${restaurant.name} from favorites!' 
                                        : 'Added ${restaurant.name} to favorites!'
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(230),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                restaurant.isFavorite ? Icons.favorite : Icons.favorite_border, 
                                size: 22, 
                                color: restaurant.isFavorite ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Color(0xFFFFB68B)), // Matching vibrant golden/orange
                                const SizedBox(width: 6),
                                Text(
                                  restaurant.rating.toString(),
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  restaurant.name,
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontSize: 20,
                                  ) ?? const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onBackground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  restaurant.deliveryFee == 0 ? "Free Delivery" : "\$${restaurant.deliveryFee.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                '25-30 min', // Placeholder time
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 24),
                              const Icon(Icons.location_on_rounded, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  restaurant.city,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    // Assuming Laravel base URL if relative path
    return 'http://10.0.2.2:8000/storage/$url';
  }
}
