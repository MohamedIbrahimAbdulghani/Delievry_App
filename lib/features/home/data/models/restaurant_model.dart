import '../../domain/entities/restaurant_entity.dart';

class RestaurantModel extends RestaurantEntity {
  const RestaurantModel({
    required super.id,
    required super.name,
    super.nameAr,
    super.nameEn,
    required super.slug,
    required super.city,
    super.cityAr,
    super.cityEn,
    required super.address,
    super.addressAr,
    super.addressEn,
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
      name: json['name'] ?? '',
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      slug: json['slug'] ?? '',
      city: json['city'] ?? '',
      cityAr: json['city_ar'],
      cityEn: json['city_en'],
      address: json['address'] ?? '',
      addressAr: json['address_ar'],
      addressEn: json['address_en'],
      phone: json['phone'] ?? '',
      deliveryFee: double.parse((json['delivery_fee'] ?? '0').toString()),
      isActive: json['is_active'] ?? false,
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
      'city_ar': cityAr,
      'city_en': cityEn,
      'address': address,
      'address_ar': addressAr,
      'address_en': addressEn,
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
