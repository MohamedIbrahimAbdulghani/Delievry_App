import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final cart = await remoteDataSource.getCart();
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addItem(int productId, int quantity, Map<String, dynamic>? options) async {
    try {
      final cart = await remoteDataSource.addItem(productId, quantity, options);
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateItem(int lineId, int quantity, Map<String, dynamic>? options) async {
    try {
      final cart = await remoteDataSource.updateItem(lineId, quantity, options);
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeItem(int lineId) async {
    try {
      final cart = await remoteDataSource.removeItem(lineId);
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    try {
      final cart = await remoteDataSource.clearCart();
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
