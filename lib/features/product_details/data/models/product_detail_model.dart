import '../../domain/entities/product_detail_entity.dart';
import 'variation_model.dart';
import 'addon_model.dart';

class ProductDetailModel extends ProductDetailEntity {
  const ProductDetailModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    required super.slug,
    required super.description,
    required super.price,
    required super.category,
    required super.isAvailable,
    super.imageUrl,
    required super.variations,
    required super.addons,
    required super.imageUrls,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      category: json['category'],
      isAvailable: json['is_available'],
      imageUrl: json['image_url'],
      variations: (json['variations'] as List?)
              ?.map((v) => VariationModel.fromJson(v))
              .toList() ??
          [],
      addons: (json['addons'] as List?)
              ?.map((a) => AddonModel.fromJson(a))
              .toList() ??
          [],
      imageUrls: (json['image_urls'] as List?)?.cast<String>() ?? [],
    );
  }
}
