import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';

abstract class DeliveryRepository {
  Future<Either<Failure, List<OrderEntity>>> getAssignedOrders();
  Future<Either<Failure, OrderEntity>> updateDeliveryStatus(int orderId, String status);
  Future<Either<Failure, OrderEntity>> updateDriverLocation(int orderId, double latitude, double longitude);
  Future<Either<Failure, UserEntity>> toggleAvailability(bool isOnline);
  Future<Either<Failure, Map<String, dynamic>> > getDriverEarnings();
  Future<Either<Failure, List<OrderEntity>>> getDeliveryHistory({int page = 1});
  Future<Either<Failure, OrderEntity>> acceptOrder(int orderId);
}
