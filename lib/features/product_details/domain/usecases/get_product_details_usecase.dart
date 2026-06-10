import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_detail_entity.dart';
import '../repositories/product_repository.dart';

class GetProductDetailsUseCase {
  final ProductRepository repository;

  GetProductDetailsUseCase(this.repository);

  Future<Either<Failure, ProductDetailEntity>> call(int id) async {
    return await repository.getProductDetails(id);
  }
}
