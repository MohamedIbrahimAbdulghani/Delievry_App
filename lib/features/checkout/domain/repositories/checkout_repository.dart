import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, bool>> placeOrder({
    required String address,
    required String paymentMethod,
    String? notes,
  });
}
