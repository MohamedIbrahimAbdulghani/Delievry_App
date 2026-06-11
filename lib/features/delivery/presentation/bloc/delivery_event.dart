import 'package:equatable/equatable.dart';

abstract class DeliveryEvent extends Equatable {
  const DeliveryEvent();

  @override
  List<Object?> get props => [];
}

class FetchAssignedOrders extends DeliveryEvent {}

class UpdateDeliveryStatus extends DeliveryEvent {
  final int orderId;
  final String status;

  const UpdateDeliveryStatus({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class UpdateDriverLocation extends DeliveryEvent {
  final int orderId;
  final double latitude;
  final double longitude;

  const UpdateDriverLocation({
    required this.orderId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [orderId, latitude, longitude];
}

class ToggleAvailability extends DeliveryEvent {
  final bool isOnline;

  const ToggleAvailability({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}

class FetchDriverEarnings extends DeliveryEvent {}

class FetchDeliveryHistory extends DeliveryEvent {
  final int page;

  const FetchDeliveryHistory({this.page = 1});

  @override
  List<Object?> get props => [page];
}
