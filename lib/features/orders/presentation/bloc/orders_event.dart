import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class FetchOrders extends OrdersEvent {}

class FetchOrderDetails extends OrdersEvent {
  final int id;
  const FetchOrderDetails(this.id);
  @override
  List<Object?> get props => [id];
}

class ReorderEvent extends OrdersEvent {
  final int id;
  const ReorderEvent(this.id);
  @override
  List<Object?> get props => [id];
}
