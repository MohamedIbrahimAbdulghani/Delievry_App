import 'package:dartz/dartz.dart';
import '../../../../core/network/dio_client.dart';
import '../models/favorite_model.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/entities/favorite_entity.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final DioClient dioClient;

  FavoritesRepositoryImpl({required this.dioClient});

  @override
  Future<Either<Exception, List<FavoriteEntity>>> getFavorites() async {
    try {
      final response = await dioClient.get('/favorites');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        final favorites = data.map((json) => FavoriteModel.fromJson(json)).toList();
        return Right(favorites);
      } else {
        return Left(Exception(response.data['message'] ?? 'Failed to load favorites'));
      }
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> toggleFavorite(String id, bool isFavorite) async {
    try {
      final response = await dioClient.post('/favorites/toggle/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      } else {
        return Left(Exception(response.data['message'] ?? 'Failed to toggle favorite'));
      }
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
