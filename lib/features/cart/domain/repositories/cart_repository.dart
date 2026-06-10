import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> addItem(int productId, int quantity, Map<String, dynamic>? options);
  Future<Either<Failure, CartEntity>> updateItem(int lineId, int quantity, Map<String, dynamic>? options);
  Future<Either<Failure, CartEntity>> removeItem(int lineId);
  Future<Either<Failure, CartEntity>> clearCart();
}
