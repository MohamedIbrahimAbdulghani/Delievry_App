import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/restaurant_entity.dart';
import '../repositories/home_repository.dart';

class GetRestaurantsUseCase {
  final HomeRepository repository;

  GetRestaurantsUseCase(this.repository);

  Future<Either<Failure, List<RestaurantEntity>>> call({
    int page = 1,
    String? categoryId,
    String? query,
  }) async {
    return await repository.getRestaurants(
      page: page,
      categoryId: categoryId,
      query: query,
    );
  }
}
