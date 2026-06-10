import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/checkout_repository.dart';

class PlaceOrderUseCase {
  final CheckoutRepository repository;

  PlaceOrderUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String address,
    required String paymentMethod,
    String? notes,
  }) async {
    return await repository.placeOrder(
      address: address,
      paymentMethod: paymentMethod,
      notes: notes,
    );
  }
}
