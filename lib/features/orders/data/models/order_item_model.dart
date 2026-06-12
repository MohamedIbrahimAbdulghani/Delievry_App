import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    super.options,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'],
      unitPrice: double.parse((json['unit_price'] ?? '0').toString()),
      options: json['options'] != null
          ? Map<String, dynamic>.from(json['options'])
          : null,
    );
  }
}
