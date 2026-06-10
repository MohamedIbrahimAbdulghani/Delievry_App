import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;
  GetCartUseCase(this.repository);
  Future<Either<Failure, CartEntity>> call() async => await repository.getCart();
}

class AddToCartUseCase {
  final CartRepository repository;
  AddToCartUseCase(this.repository);
  Future<Either<Failure, CartEntity>> call(int productId, int quantity, {Map<String, dynamic>? options}) async =>
      await repository.addItem(productId, quantity, options);
}

class UpdateCartItemUseCase {
  final CartRepository repository;
  UpdateCartItemUseCase(this.repository);
  Future<Either<Failure, CartEntity>> call(int lineId, int quantity, {Map<String, dynamic>? options}) async =>
      await repository.updateItem(lineId, quantity, options);
}

class RemoveFromCartUseCase {
  final CartRepository repository;
  RemoveFromCartUseCase(this.repository);
  Future<Either<Failure, CartEntity>> call(int lineId) async => await repository.removeItem(lineId);
}

class ClearCartUseCase {
  final CartRepository repository;
  ClearCartUseCase(this.repository);
  Future<Either<Failure, CartEntity>> call() async => await repository.clearCart();
}
