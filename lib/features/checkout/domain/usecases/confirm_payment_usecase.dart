import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/checkout_repository.dart';

class ConfirmPaymentUseCase {
  final CheckoutRepository repository;

  ConfirmPaymentUseCase(this.repository);

  Future<Either<Failure, void>> call(String paymentIntentId) {
    return repository.confirmPayment(paymentIntentId);
  }
}
