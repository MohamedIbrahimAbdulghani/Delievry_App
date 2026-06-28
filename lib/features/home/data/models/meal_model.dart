import '../../domain/entities/meal_entity.dart';

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    super.nameAr,
    super.nameEn,
    required super.slug,
    required super.description,
    super.descriptionAr,
    super.descriptionEn,
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
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      slug: json['slug'],
      description: json['description'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
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
      'category_ar': categoryAr,
      'category_en': categoryEn,
      'is_available': isAvailable,
      'image_url': imageUrl,
    };
  }
}
