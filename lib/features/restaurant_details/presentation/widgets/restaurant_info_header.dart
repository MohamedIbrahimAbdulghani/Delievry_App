import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/restaurant_detail_entity.dart';

class RestaurantInfoHeader extends StatelessWidget {
  final RestaurantDetailEntity restaurant;

  const RestaurantInfoHeader({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ) ?? const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onBackground,
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(50), width: 1),
                ),
                child: const Text(
                  'Open',
                  style: TextStyle(
                    color: AppColors.primary, 
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5), // Soft amber background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB68B), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      restaurant.rating.toString(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF994700),
                      ) ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '(${restaurant.totalReviews} reviews)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ) ?? const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'See details', 
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoItem(context, Icons.delivery_dining_rounded, restaurant.deliveryFee == 0 ? "Free Delivery" : '\$${restaurant.deliveryFee.toStringAsFixed(2)}'),
              const SizedBox(width: 24),
              _buildInfoItem(context, Icons.access_time_rounded, '25-30 min'),
              const SizedBox(width: 24),
              Expanded(child: _buildInfoItem(context, Icons.location_on_rounded, restaurant.city)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.outline.withAlpha(50),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 16),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ) ?? const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
