import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      final banners = await remoteDataSource.getBanners();
      return Right(banners);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants({
    int page = 1,
    String? categoryId,
    String? query,
  }) async {
    try {
      final restaurants = await remoteDataSource.getRestaurants(
        page: page,
        categoryId: categoryId,
        query: query,
      );
      return Right(restaurants);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getPopularMeals({
    int page = 1,
    String? categoryId,
    String? query,
  }) async {
    try {
      final meals = await remoteDataSource.getPopularMeals(
        page: page,
        categoryId: categoryId,
        query: query,
      );
      return Right(meals);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
