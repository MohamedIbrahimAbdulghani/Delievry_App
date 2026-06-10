import 'package:dartz/dartz.dart';
import '../repositories/favorites_repository.dart';
import '../entities/favorite_entity.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<Either<Exception, List<FavoriteEntity>>> call() async {
    return await repository.getFavorites();
  }
}

class ToggleFavoriteUseCase {
  final FavoritesRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<Either<Exception, void>> call(String id, bool isFavorite) async {
    return await repository.toggleFavorite(id, isFavorite);
  }
}
