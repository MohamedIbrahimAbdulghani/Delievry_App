import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class FetchCart extends CartEvent {}

class AddItemToCart extends CartEvent {
  final int productId;
  final int quantity;
  final Map<String, dynamic>? options;
  const AddItemToCart({required this.productId, required this.quantity, this.options});
  @override
  List<Object?> get props => [productId, quantity, options];
}

class UpdateItemQuantity extends CartEvent {
  final int lineId;
  final int quantity;
  const UpdateItemQuantity({required this.lineId, required this.quantity});
  @override
  List<Object?> get props => [lineId, quantity];
}

class RemoveItemFromCart extends CartEvent {
  final int lineId;
  const RemoveItemFromCart(this.lineId);
  @override
  List<Object?> get props => [lineId];
}

class ClearCart extends CartEvent {}
