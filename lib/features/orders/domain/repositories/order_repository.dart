import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders({int page = 1});
  Future<Either<Failure, OrderEntity>> getOrderDetails(int id);
  Future<Either<Failure, bool>> reorder(int id);
}
