import '../../domain/entities/meal_entity.dart';

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    required super.slug,
    required super.description,
    required super.price,
    required super.category,
    required super.isAvailable,
    super.imageUrl,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      category: json['category'],
      isAvailable: json['is_available'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price.toString(),
      'category': category,
      'is_available': isAvailable,
      'image_url': imageUrl,
    };
  }
}
