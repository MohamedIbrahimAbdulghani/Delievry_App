import '../../../home/data/models/restaurant_model.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.restaurant,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.deliveryAddress,
    required super.createdAt,
    super.notes,
    super.latitude,
    super.longitude,
    super.driverLatitude,
    super.driverLongitude,
    super.driver,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // The backend returns 'total', not 'total_amount'
    final totalRaw = json['total'] ?? json['total_amount'] ?? '0';

    // 'restaurant' may be null if not loaded; fall back to a minimal placeholder
    final restaurantJson = json['restaurant'];
    final driverJson = json['driver'];

    return OrderModel(
      id: json['id'],
      restaurant: restaurantJson != null
          ? RestaurantModel.fromJson(Map<String, dynamic>.from(restaurantJson))
          : RestaurantModel(
              id: json['restaurant_id'] ?? 0,
              name: 'Unknown Restaurant',
              slug: '',
              city: '',
              address: '',
              phone: '',
              deliveryFee: 0,
              isActive: true,
            ),
      items: (json['items'] as List?)
              ?.map((i) => OrderItemModel.fromJson(Map<String, dynamic>.from(i)))
              .toList() ??
          [],
      totalAmount: double.parse(totalRaw.toString()),
      status: _parseStatus(json['status'] ?? 'pending'),
      deliveryAddress: json['delivery_address'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      notes: json['notes'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      driverLatitude: json['driver_latitude'] != null ? double.tryParse(json['driver_latitude'].toString()) : null,
      driverLongitude: json['driver_longitude'] != null ? double.tryParse(json['driver_longitude'].toString()) : null,
      driver: driverJson != null ? UserProfileModel.fromJson(Map<String, dynamic>.from(driverJson)) : null,
    );
  }

  static OrderStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        return OrderStatus.pending;
      case 'preparing':
      case 'processing':
      case 'accepted':
        return OrderStatus.preparing;
      case 'heading_to_restaurant':
        return OrderStatus.heading_to_restaurant;
      case 'picked_up':
        return OrderStatus.picked_up;
      case 'on_the_way':
      case 'out_for_delivery':
        return OrderStatus.out_for_delivery;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'failed':
        return OrderStatus.failed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
