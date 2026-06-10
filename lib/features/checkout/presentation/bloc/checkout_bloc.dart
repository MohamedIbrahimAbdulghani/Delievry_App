import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/place_order_usecase.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final PlaceOrderUseCase placeOrderUseCase;

  CheckoutBloc({required this.placeOrderUseCase}) : super(CheckoutInitial()) {
    on<PlaceOrderEvent>(_onPlaceOrder);
  }

  Future<void> _onPlaceOrder(PlaceOrderEvent event, Emitter<CheckoutState> emit) async {
    emit(CheckoutLoading());
    final result = await placeOrderUseCase(
      address: event.address,
      paymentMethod: event.paymentMethod,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(CheckoutError(failure.message)),
      (success) => emit(CheckoutSuccess()),
    );
  }
}
