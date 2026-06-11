import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/delivery_repository.dart';

class GetDriverEarningsUseCase {
  final DeliveryRepository repository;

  GetDriverEarningsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getDriverEarnings();
  }
}
