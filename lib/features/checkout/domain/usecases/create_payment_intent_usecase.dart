import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/checkout_repository.dart';

class CreatePaymentIntentUseCase {
  final CheckoutRepository repository;

  CreatePaymentIntentUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String address,
    String? notes,
  }) async {
    return await repository.createPaymentIntent(
      address: address,
      notes: notes,
    );
  }
}
