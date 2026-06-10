import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/meal_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<OrderEntity>>> getAllOrders();
  Future<Either<Failure, OrderEntity>> updateOrderStatus(int orderId, String status);

  Future<Either<Failure, List<RestaurantEntity>>> getAllRestaurants();
  Future<Either<Failure, RestaurantEntity>> createRestaurant(Map<String, dynamic> data);
  Future<Either<Failure, RestaurantEntity>> updateRestaurant(int id, Map<String, dynamic> data);
  Future<Either<Failure, Unit>> deleteRestaurant(int id);

  Future<Either<Failure, List<MealEntity>>> getAllMeals();
  Future<Either<Failure, MealEntity>> createMeal(Map<String, dynamic> data);
  Future<Either<Failure, MealEntity>> updateMeal(int id, Map<String, dynamic> data);
  Future<Either<Failure, Unit>> deleteMeal(int id);

  Future<Either<Failure, List<UserEntity>>> getAllUsers();
  Future<Either<Failure, UserEntity>> updateUser(int id, Map<String, dynamic> data);
  Future<Either<Failure, Unit>> deleteUser(int id);

  Future<Either<Failure, List<Map<String, dynamic>>>> getDrivers();
  Future<Either<Failure, Unit>> saveDrivers(List<Map<String, dynamic>> drivers);

  Future<Either<Failure, Map<String, dynamic>>> getSettings();
  Future<Either<Failure, Unit>> saveSettings(Map<String, dynamic> settings);
}
