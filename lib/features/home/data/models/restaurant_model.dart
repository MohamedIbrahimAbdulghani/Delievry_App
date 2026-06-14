import '../../domain/entities/restaurant_entity.dart';

class RestaurantModel extends RestaurantEntity {
  const RestaurantModel({
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
    super.rating,
    super.totalReviews,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
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
      rating: double.parse((json['rating'] ?? 0.0).toString()),
      totalReviews: int.parse((json['total_reviews'] ?? 0).toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'city': city,
      'address': address,
      'phone': phone,
      'delivery_fee': deliveryFee.toString(),
      'is_active': isActive,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
      'rating': rating,
      'total_reviews': totalReviews,
    };
  }
}
