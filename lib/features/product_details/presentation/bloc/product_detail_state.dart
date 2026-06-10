import 'package:equatable/equatable.dart';
import '../../domain/entities/product_detail_entity.dart';

abstract class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final ProductDetailEntity product;
  final int quantity;
  final List<String> selectedAddonIds;
  final String? selectedVariationId;

  const ProductDetailLoaded({
    required this.product,
    this.quantity = 1,
    this.selectedAddonIds = const [],
    this.selectedVariationId,
  });

  double get totalPrice {
    double basePrice = product.price;
    
    // Add variation price difference if applicable
    if (selectedVariationId != null) {
      final variation = product.variations.firstWhere((v) => v.id == selectedVariationId);
      basePrice += variation.price;
    }

    // Add selected addons prices
    for (final id in selectedAddonIds) {
      final addon = product.addons.firstWhere((a) => a.id == id);
      basePrice += addon.price;
    }

    return basePrice * quantity;
  }

  ProductDetailLoaded copyWith({
    ProductDetailEntity? product,
    int? quantity,
    List<String>? selectedAddonIds,
    String? selectedVariationId,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedAddonIds: selectedAddonIds ?? this.selectedAddonIds,
      selectedVariationId: selectedVariationId ?? this.selectedVariationId,
    );
  }

  @override
  List<Object?> get props => [product, quantity, selectedAddonIds, selectedVariationId];
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
