import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/review_entity.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

class RestaurantReviews extends StatelessWidget {
  final List<ReviewEntity> reviews;

  const RestaurantReviews({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)?.noReviewsYet ?? 'No reviews yet.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: review.userImageUrl != null ? NetworkImage(review.userImageUrl!) : null,
                    child: review.userImageUrl == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.userName,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Text(
                          '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      Icons.star,
                      size: 16,
                      color: i < review.rating ? Colors.amber : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review.comment,
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        );
      },
    );
  }
}
