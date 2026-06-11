import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../repositories/delivery_repository.dart';

class UpdateDeliveryStatusUseCase {
  final DeliveryRepository repository;

  UpdateDeliveryStatusUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(int orderId, String status) {
    return repository.updateDeliveryStatus(orderId, status);
  }
}
