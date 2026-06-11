import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';

abstract class DeliveryState extends Equatable {
  const DeliveryState();

  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {}

class DeliveryLoading extends DeliveryState {}

class DeliveryError extends DeliveryState {
  final String message;
  const DeliveryError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeliveryLoaded extends DeliveryState {
  final List<OrderEntity> assignedOrders;
  final UserEntity driver;
  final Map<String, dynamic> earnings;
  final List<OrderEntity> history;

  const DeliveryLoaded({
    required this.assignedOrders,
    required this.driver,
    required this.earnings,
    required this.history,
  });

  DeliveryLoaded copyWith({
    List<OrderEntity>? assignedOrders,
    UserEntity? driver,
    Map<String, dynamic>? earnings,
    List<OrderEntity>? history,
  }) {
    return DeliveryLoaded(
      assignedOrders: assignedOrders ?? this.assignedOrders,
      driver: driver ?? this.driver,
      earnings: earnings ?? this.earnings,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [assignedOrders, driver, earnings, history];
}

class DeliveryActionSuccess extends DeliveryState {
  final String message;
  const DeliveryActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
