import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.nameAr,
    super.nameEn,
    super.imageUrl,
    super.isVisible = true,
    super.restaurantIds = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      imageUrl: json['image_url'],
      isVisible: json['is_visible'] ?? true,
      restaurantIds: (json['restaurant_ids'] as List?)?.map((e) => int.parse(e.toString())).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'name_en': nameEn,
      'image_url': imageUrl,
      'is_visible': isVisible,
      'restaurant_ids': restaurantIds,
    };
  }
}
