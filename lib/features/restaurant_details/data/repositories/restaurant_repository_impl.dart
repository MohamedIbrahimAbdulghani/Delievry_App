import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/restaurant_detail_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RestaurantDetailEntity>> getRestaurantDetails(int id) async {
    try {
      final details = await remoteDataSource.getRestaurantDetails(id);
      return Right(details);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(int id) async {
    try {
      final result = await remoteDataSource.toggleFavorite(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
