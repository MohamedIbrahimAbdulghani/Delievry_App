import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meal_entity.dart';
import '../repositories/home_repository.dart';

class GetPopularMealsUseCase {
  final HomeRepository repository;

  GetPopularMealsUseCase(this.repository);

  Future<Either<Failure, List<MealEntity>>> call({
    int page = 1,
    String? categoryId,
    String? query,
  }) async {
    return await repository.getPopularMeals(
      page: page,
      categoryId: categoryId,
      query: query,
    );
  }
}
