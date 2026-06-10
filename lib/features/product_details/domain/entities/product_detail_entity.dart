import '../../../home/domain/entities/meal_entity.dart';
import 'variation_entity.dart';
import 'addon_entity.dart';

class ProductDetailEntity extends MealEntity {
  final List<VariationEntity> variations;
  final List<AddonEntity> addons;
  final List<String> imageUrls;

  const ProductDetailEntity({
    required super.id,
    required super.restaurantId,
    required super.name,
    required super.slug,
    required super.description,
    required super.price,
    required super.category,
    required super.isAvailable,
    super.imageUrl,
    required this.variations,
    required this.addons,
    required this.imageUrls,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        variations,
        addons,
        imageUrls,
      ];
}
