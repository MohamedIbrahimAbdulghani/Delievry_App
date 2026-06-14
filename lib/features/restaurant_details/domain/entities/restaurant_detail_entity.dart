import '../../../home/domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/meal_entity.dart';
import 'review_entity.dart';

class RestaurantDetailEntity extends RestaurantEntity {
  final List<MealEntity> products;
  final List<ReviewEntity> reviews;
  final List<String> categories;

  const RestaurantDetailEntity({
    required super.id,
    required super.name,
    required super.slug,
    required super.city,
    required super.address,
    required super.phone,
    required super.deliveryFee,
    required super.isActive,
    super.imageUrl,
    required this.products,
    required this.reviews,
    required this.categories,
    required super.rating,
    required super.totalReviews,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        products,
        reviews,
        categories,
      ];
}
