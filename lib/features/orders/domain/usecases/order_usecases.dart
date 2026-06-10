import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;
  GetOrdersUseCase(this.repository);
  Future<Either<Failure, List<OrderEntity>>> call({int page = 1}) async => await repository.getOrders(page: page);
}

class GetOrderDetailsUseCase {
  final OrderRepository repository;
  GetOrderDetailsUseCase(this.repository);
  Future<Either<Failure, OrderEntity>> call(int id) async => await repository.getOrderDetails(id);
}

class ReorderUseCase {
  final OrderRepository repository;
  ReorderUseCase(this.repository);
  Future<Either<Failure, bool>> call(int id) async => await repository.reorder(id);
}
