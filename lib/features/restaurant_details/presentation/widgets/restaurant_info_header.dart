import 'package:flutter/material.dart';
import '../../domain/entities/restaurant_detail_entity.dart';
import 'package:delievry_app/l10n/app_localizations.dart';
import '../../../../core/utils/data_localization_helper.dart';

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
          Text(
            restaurant.name,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ) ?? TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Plus Jakarta Sans',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.withOpacity(0.2) : const Color(0xFFFFF4E5), // Soft amber background
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
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.orange[200] : const Color(0xFF994700),
                      ) ?? TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.orange[200] : const Color(0xFF994700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)?.reviewsCount(restaurant.totalReviews) ??
                    (Localizations.localeOf(context).languageCode == 'ar'
                        ? '(${DataLocalizationHelper.formatNumber(context, restaurant.totalReviews)} تقييمات)'
                        : '(${restaurant.totalReviews} reviews)'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ) ?? TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoItem(
                context,
                Icons.delivery_dining_rounded,
                restaurant.deliveryFee == 0
                    ? (Localizations.localeOf(context).languageCode == 'ar' ? 'توصيل مجاني' : 'Free Delivery')
                    : DataLocalizationHelper.formatCurrency(context, restaurant.deliveryFee),
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                context,
                Icons.access_time_rounded,
                '${DataLocalizationHelper.formatNumber(context, 25)}-${DataLocalizationHelper.formatNumber(context, 30)} ${AppLocalizations.of(context)?.min ?? "min"}',
              ),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 16),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ) ?? TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
