import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/restaurant_detail_entity.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, RestaurantDetailEntity>> getRestaurantDetails(int id);
  Future<Either<Failure, bool>> toggleFavorite(int id);
  Future<Either<Failure, Unit>> submitReview({
    required int orderId,
    required double rating,
    required String comment,
    int? notificationId,
  });
}
