import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../repositories/delivery_repository.dart';

class AcceptOrderUseCase {
  final DeliveryRepository repository;

  AcceptOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(int orderId) {
    return repository.acceptOrder(orderId);
  }
}
