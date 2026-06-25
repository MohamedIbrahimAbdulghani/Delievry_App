import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/meal_entity.dart';

class CartItemEntity extends Equatable {
  final int id; // Line item ID
  final MealEntity product;
  final int quantity;
  final Map<String, dynamic>? options;

  const CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
    this.options,
  });

  CartItemEntity copyWith({
    int? id,
    MealEntity? product,
    int? quantity,
    Map<String, dynamic>? options,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      options: options ?? this.options,
    );
  }

  double get totalPrice => (product.price * quantity);

  @override
  List<Object?> get props => [id, product, quantity, options];
}
