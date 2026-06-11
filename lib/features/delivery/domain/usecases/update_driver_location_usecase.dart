import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../repositories/delivery_repository.dart';

class UpdateDriverLocationUseCase {
  final DeliveryRepository repository;

  UpdateDriverLocationUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(int orderId, double latitude, double longitude) {
    return repository.updateDriverLocation(orderId, latitude, longitude);
  }
}
