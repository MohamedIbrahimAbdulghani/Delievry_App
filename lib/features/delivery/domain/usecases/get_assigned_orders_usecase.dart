import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../repositories/delivery_repository.dart';

class GetAssignedOrdersUseCase {
  final DeliveryRepository repository;

  GetAssignedOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() {
    return repository.getAssignedOrders();
  }
}
