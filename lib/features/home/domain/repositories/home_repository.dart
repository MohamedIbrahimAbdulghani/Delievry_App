import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/banner_entity.dart';
import '../entities/category_entity.dart';
import '../entities/meal_entity.dart';
import '../entities/restaurant_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<BannerEntity>>> getBanners();
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants({
    int page = 1,
    String? categoryId,
    String? query,
  });
  Future<Either<Failure, List<MealEntity>>> getPopularMeals({
    int page = 1,
    String? categoryId,
    String? query,
  });
}
