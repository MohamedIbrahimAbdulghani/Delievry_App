import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/restaurant_repository.dart';

class ToggleFavoriteRestaurantUseCase {
  final RestaurantRepository repository;

  ToggleFavoriteRestaurantUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await repository.toggleFavorite(id);
  }
}
