import 'package:dartz/dartz.dart';
import '../entities/favorite_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Exception, List<FavoriteEntity>>> getFavorites();
  Future<Either<Exception, void>> toggleFavorite(String id, bool isFavorite);
}
