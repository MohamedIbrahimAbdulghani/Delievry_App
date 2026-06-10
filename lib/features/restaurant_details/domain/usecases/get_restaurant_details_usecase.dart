import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/restaurant_detail_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantDetailsUseCase {
  final RestaurantRepository repository;

  GetRestaurantDetailsUseCase(this.repository);

  Future<Either<Failure, RestaurantDetailEntity>> call(int id) async {
    return await repository.getRestaurantDetails(id);
  }
}
