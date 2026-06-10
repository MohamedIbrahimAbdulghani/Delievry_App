import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/restaurant_entity.dart';
import 'order_item_entity.dart';

enum OrderStatus { pending, confirmed, preparing, out_for_delivery, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get apiValue {
    switch (this) {
      case OrderStatus.pending: return 'pending';
      case OrderStatus.confirmed: return 'confirmed';
      case OrderStatus.preparing: return 'preparing';
      case OrderStatus.out_for_delivery: return 'out_for_delivery';
      case OrderStatus.delivered: return 'delivered';
      case OrderStatus.cancelled: return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.out_for_delivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}

class OrderEntity extends Equatable {
  final int id;
  final RestaurantEntity restaurant;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final DateTime createdAt;
  final String? notes;
  final double? latitude;
  final double? longitude;

  const OrderEntity({
    required this.id,
    required this.restaurant,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.createdAt,
    this.notes,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        restaurant,
        items,
        totalAmount,
        status,
        deliveryAddress,
        createdAt,
        notes,
        latitude,
        longitude,
      ];
}
