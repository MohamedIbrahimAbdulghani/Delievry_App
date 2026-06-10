import 'package:equatable/equatable.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class PlaceOrderEvent extends CheckoutEvent {
  final String address;
  final String paymentMethod;
  final String? notes;
  const PlaceOrderEvent({required this.address, required this.paymentMethod, this.notes});
  @override
  List<Object?> get props => [address, paymentMethod, notes];
}
