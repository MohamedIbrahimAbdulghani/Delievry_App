import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/review_entity.dart';

class RestaurantReviews extends StatelessWidget {
  final List<ReviewEntity> reviews;

  const RestaurantReviews({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text('No reviews yet.'));
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
            color: AppColors.background,
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      Icons.star,
                      size: 16,
                      color: i < review.rating ? Colors.amber : Colors.grey[300],
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review.comment,
                style: const TextStyle(fontSize: 14, color: AppColors.onBackground),
              ),
            ],
          ),
        );
      },
    );
  }
}
