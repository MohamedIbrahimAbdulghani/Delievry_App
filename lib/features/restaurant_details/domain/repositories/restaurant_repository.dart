import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/restaurant_detail_entity.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, RestaurantDetailEntity>> getRestaurantDetails(int id);
  Future<Either<Failure, bool>> toggleFavorite(int id);
}
