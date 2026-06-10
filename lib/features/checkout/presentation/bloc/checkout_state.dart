import 'package:equatable/equatable.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override
  List<Object?> get props => [message];
}
