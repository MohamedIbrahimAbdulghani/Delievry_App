import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../repositories/delivery_repository.dart';

class GetDeliveryHistoryUseCase {
  final DeliveryRepository repository;

  GetDeliveryHistoryUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call({int page = 1}) {
    return repository.getDeliveryHistory(page: page);
  }
}
