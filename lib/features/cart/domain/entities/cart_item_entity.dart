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

  double get totalPrice => (product.price * quantity);

  @override
  List<Object?> get props => [id, product, quantity, options];
}
