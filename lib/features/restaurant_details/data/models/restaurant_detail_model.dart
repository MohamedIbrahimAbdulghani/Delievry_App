import '../../../home/data/models/meal_model.dart';
import '../../domain/entities/restaurant_detail_entity.dart';
import 'review_model.dart';

class RestaurantDetailModel extends RestaurantDetailEntity {
  const RestaurantDetailModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.city,
    required super.address,
    required super.phone,
    required super.deliveryFee,
    required super.isActive,
    super.imageUrl,
    super.isFavorite,
    required super.products,
    required super.reviews,
    required super.categories,
    required super.rating,
    required super.totalReviews,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      city: json['city'],
      address: json['address'],
      phone: json['phone'],
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      isActive: json['is_active'],
      imageUrl: json['image_url'],
      isFavorite: json['is_favorite'] ?? false,
      products: (json['products'] as List?)
              ?.map((p) => MealModel.fromJson(p))
              .toList() ??
          [],
      reviews: (json['reviews'] as List?)
              ?.map((r) => ReviewModel.fromJson(r))
              .toList() ??
          [],
      categories: (json['products'] as List?)
              ?.map((p) => p['category'] as String)
              .toSet()
              .toList() ??
          [],
      rating: double.parse((json['rating'] ?? 0.0).toString()),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}
