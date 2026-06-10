import '../../../home/data/models/meal_model.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
    super.options,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      product: MealModel.fromJson(json['product']),
      quantity: json['quantity'],
      options: json['options'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product.id,
      'quantity': quantity,
      'options': options,
    };
  }
}
