import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, bool>> placeOrder({
    required String address,
    required String paymentMethod,
    String? notes,
  });

  Future<Either<Failure, String>> createPaymentIntent({
    required String address,
    String? notes,
  });

  Future<Either<Failure, void>> confirmPayment(String paymentIntentId);
}
