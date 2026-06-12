import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/restaurant_entity.dart';
import '../../../profile/domain/entities/user_profile_entity.dart';
import 'order_item_entity.dart';

// ignore: constant_identifier_names
enum OrderStatus { pending, confirmed, preparing, accepted, heading_to_restaurant, picked_up, on_the_way, out_for_delivery, delivered, failed, cancelled }

extension OrderStatusX on OrderStatus {
  String get apiValue {
    switch (this) {
      case OrderStatus.pending: return 'pending';
      case OrderStatus.confirmed: return 'confirmed';
      case OrderStatus.preparing: return 'preparing';
      case OrderStatus.accepted: return 'accepted';
      case OrderStatus.heading_to_restaurant: return 'heading_to_restaurant';
      case OrderStatus.picked_up: return 'picked_up';
      case OrderStatus.on_the_way: return 'on_the_way';
      case OrderStatus.out_for_delivery: return 'out_for_delivery';
      case OrderStatus.delivered: return 'delivered';
      case OrderStatus.failed: return 'failed';
      case OrderStatus.cancelled: return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.accepted: return 'Accepted';
      case OrderStatus.heading_to_restaurant: return 'Heading to Restaurant';
      case OrderStatus.picked_up: return 'Picked Up';
      case OrderStatus.on_the_way: return 'On the Way';
      case OrderStatus.out_for_delivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.failed: return 'Failed';
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
  final double? driverLatitude;
  final double? driverLongitude;
  final UserProfileEntity? driver;

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
    this.driverLatitude,
    this.driverLongitude,
    this.driver,
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
        driverLatitude,
        driverLongitude,
        driver,
      ];
}
