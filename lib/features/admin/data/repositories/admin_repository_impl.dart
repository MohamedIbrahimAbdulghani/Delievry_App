import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/meal_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders() async {
    try {
      final orders = await remoteDataSource.getAllOrders();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(int orderId, String status) async {
    try {
      final order = await remoteDataSource.updateOrderStatus(orderId, status);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RestaurantEntity>>> getAllRestaurants() async {
    try {
      final restaurants = await remoteDataSource.getAllRestaurants();
      return Right(restaurants);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RestaurantEntity>> createRestaurant(Map<String, dynamic> data) async {
    try {
      final restaurant = await remoteDataSource.createRestaurant(data);
      return Right(restaurant);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RestaurantEntity>> updateRestaurant(int id, Map<String, dynamic> data) async {
    try {
      final restaurant = await remoteDataSource.updateRestaurant(id, data);
      return Right(restaurant);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRestaurant(int id) async {
    try {
      await remoteDataSource.deleteRestaurant(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getAllMeals() async {
    try {
      final meals = await remoteDataSource.getAllMeals();
      return Right(meals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MealEntity>> createMeal(Map<String, dynamic> data) async {
    try {
      final meal = await remoteDataSource.createMeal(data);
      return Right(meal);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MealEntity>> updateMeal(int id, Map<String, dynamic> data) async {
    try {
      final meal = await remoteDataSource.updateMeal(id, data);
      return Right(meal);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMeal(int id) async {
    try {
      await remoteDataSource.deleteMeal(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      final users = await remoteDataSource.getAllUsers();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final user = await remoteDataSource.updateUser(id, data);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(int id) async {
    try {
      await remoteDataSource.deleteUser(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getDrivers() async {
    try {
      final drivers = await remoteDataSource.getDrivers();
      return Right(drivers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveDrivers(List<Map<String, dynamic>> drivers) async {
    try {
      await remoteDataSource.saveDrivers(drivers);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSettings() async {
    try {
      final settings = await remoteDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSettings(Map<String, dynamic> settings) async {
    try {
      await remoteDataSource.saveSettings(settings);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
