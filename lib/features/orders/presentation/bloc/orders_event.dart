import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class FetchOrders extends OrdersEvent {}

class FetchOrderDetails extends OrdersEvent {
  final int id;
  final bool showLoading;
  const FetchOrderDetails(this.id, {this.showLoading = true});
  @override
  List<Object?> get props => [id, showLoading];
}

class ReorderEvent extends OrdersEvent {
  final int id;
  const ReorderEvent(this.id);
  @override
  List<Object?> get props => [id];
}
