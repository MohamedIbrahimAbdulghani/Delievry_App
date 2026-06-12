import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final Map<String, dynamic>? options;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.options,
  });

  double get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [id, productId, productName, quantity, unitPrice, options];
}
