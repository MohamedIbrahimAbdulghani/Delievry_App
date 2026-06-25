import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../../domain/usecases/create_payment_intent_usecase.dart';
import '../../domain/usecases/confirm_payment_usecase.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final PlaceOrderUseCase placeOrderUseCase;
  final CreatePaymentIntentUseCase createPaymentIntentUseCase;
  final ConfirmPaymentUseCase confirmPaymentUseCase;

  CheckoutBloc({
    required this.placeOrderUseCase,
    required this.createPaymentIntentUseCase,
    required this.confirmPaymentUseCase,
  }) : super(CheckoutInitial()) {
    on<PlaceOrderEvent>(_onPlaceOrder);
  }

  Future<void> _onPlaceOrder(PlaceOrderEvent event, Emitter<CheckoutState> emit) async {
    emit(CheckoutLoading());
    
    if (event.paymentMethod == 'card') {
      final intentResult = await createPaymentIntentUseCase(
        address: event.address,
        notes: event.notes,
      );

      await intentResult.fold(
        (failure) async => emit(CheckoutError(failure.message)),
        (clientSecret) async {
          try {
            await Stripe.instance.initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: clientSecret,
                merchantDisplayName: 'Delivery App',
              ),
            );
            await Stripe.instance.presentPaymentSheet();
            
            // Confirm the payment synchronously on the backend to create the order immediately
            final paymentIntentId = clientSecret.split('_secret_').first;
            final confirmResult = await confirmPaymentUseCase(paymentIntentId);
            
            confirmResult.fold(
              (failure) => emit(CheckoutError(failure.message)),
              (_) => emit(CheckoutSuccess()),
            );
            
          } on StripeException catch (e) {
            emit(CheckoutError(e.error.message ?? 'Payment failed'));
          } catch (e) {
            emit(CheckoutError(e.toString()));
          }
        },
      );
    } else {
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
}
