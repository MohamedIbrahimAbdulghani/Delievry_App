import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_detail_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductDetailEntity>> getProductDetails(int id);
}
