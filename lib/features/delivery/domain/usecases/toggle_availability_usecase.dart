import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/delivery_repository.dart';

class ToggleAvailabilityUseCase {
  final DeliveryRepository repository;

  ToggleAvailabilityUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(bool isOnline) {
    return repository.toggleAvailability(isOnline);
  }
}
