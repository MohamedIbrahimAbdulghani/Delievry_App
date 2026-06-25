import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({
    required this.items,
  });

  CartEntity copyWith({
    List<CartItemEntity>? items,
  }) {
    return CartEntity(
      items: items ?? this.items,
    );
  }

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => 5.0; // Placeholder or fetched from restaurant
  double get tax => subtotal * 0.1; // 10% placeholder
  double get total => subtotal + deliveryFee + tax;

  @override
  List<Object?> get props => [items];
}
