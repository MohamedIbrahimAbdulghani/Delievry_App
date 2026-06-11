import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/meal_entity.dart';
import '../../../home/domain/entities/category_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;
  AdminLoaded? _lastLoadedState;

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<FetchAdminData>(_onFetchAdminData);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<AssignDriverEvent>(_onAssignDriver);
    
    // Restaurants
    on<CreateRestaurantEvent>(_onCreateRestaurant);
    on<UpdateRestaurantEvent>(_onUpdateRestaurant);
    on<DeleteRestaurantEvent>(_onDeleteRestaurant);
    
    // Meals
    on<CreateMealEvent>(_onCreateMeal);
    on<UpdateMealEvent>(_onUpdateMeal);
    on<DeleteMealEvent>(_onDeleteMeal);
    
    // Categories
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    
    // Users
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    
    // System
    on<SaveSettingsEvent>(_onSaveSettings);
    on<SaveDriversEvent>(_onSaveDrivers);
  }

  Future<void> _handleCrudAction<T>({
    required Future<Either<Failure, T>> Function() action,
    required String successMessage,
    required Emitter<AdminState> emit,
  }) async {
    final result = await action();
    await result.fold(
      (failure) async {
        emit(AdminActionFailure(failure.message));
        if (_lastLoadedState != null) {
          emit(_lastLoadedState!);
        } else {
          emit(AdminError(failure.message));
        }
      },
      (_) async {
        emit(AdminActionSuccess(successMessage));
        await _fetchAdminDataHelper(emit);
      },
    );
  }

  Future<void> _onFetchAdminData(FetchAdminData event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    await _fetchAdminDataHelper(emit);
  }

  Future<void> _onUpdateOrderStatus(UpdateOrderStatusEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.updateOrderStatus(event.orderId, event.status),
      successMessage: 'Order status updated successfully',
      emit: emit,
    );
  }

  Future<void> _onAssignDriver(AssignDriverEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.assignDriver(event.orderId, event.driverId),
      successMessage: 'Driver assigned successfully',
      emit: emit,
    );
  }

  // Restaurants
  Future<void> _onCreateRestaurant(CreateRestaurantEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.createRestaurant(event.data),
      successMessage: 'Restaurant created successfully',
      emit: emit,
    );
  }

  Future<void> _onUpdateRestaurant(UpdateRestaurantEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.updateRestaurant(event.id, event.data),
      successMessage: 'Restaurant updated successfully',
      emit: emit,
    );
  }

  Future<void> _onDeleteRestaurant(DeleteRestaurantEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.deleteRestaurant(event.id),
      successMessage: 'Restaurant deleted successfully',
      emit: emit,
    );
  }

  // Meals
  Future<void> _onCreateMeal(CreateMealEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.createMeal(event.data),
      successMessage: 'Meal created successfully',
      emit: emit,
    );
  }

  Future<void> _onUpdateMeal(UpdateMealEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.updateMeal(event.id, event.data),
      successMessage: 'Meal updated successfully',
      emit: emit,
    );
  }

  Future<void> _onDeleteMeal(DeleteMealEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.deleteMeal(event.id),
      successMessage: 'Meal deleted successfully',
      emit: emit,
    );
  }

  // Categories
  Future<void> _onCreateCategory(CreateCategoryEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.createCategory(event.data),
      successMessage: 'Category created successfully',
      emit: emit,
    );
  }

  Future<void> _onUpdateCategory(UpdateCategoryEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.updateCategory(event.id, event.data),
      successMessage: 'Category updated successfully',
      emit: emit,
    );
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.deleteCategory(event.id),
      successMessage: 'Category deleted successfully',
      emit: emit,
    );
  }

  // Users
  Future<void> _onCreateUser(CreateUserEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.createUser(event.data),
      successMessage: 'User created successfully',
      emit: emit,
    );
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.updateUser(event.id, event.data),
      successMessage: 'User updated successfully',
      emit: emit,
    );
  }

  Future<void> _onDeleteUser(DeleteUserEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.deleteUser(event.id),
      successMessage: 'User deleted successfully',
      emit: emit,
    );
  }

  // System Settings
  Future<void> _onSaveSettings(SaveSettingsEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.saveSettings(event.settings),
      successMessage: 'Settings saved successfully',
      emit: emit,
    );
  }

  // Drivers
  Future<void> _onSaveDrivers(SaveDriversEvent event, Emitter<AdminState> emit) async {
    await _handleCrudAction(
      action: () => repository.saveDrivers(event.drivers),
      successMessage: 'Drivers list saved successfully',
      emit: emit,
    );
  }

  Future<void> _fetchAdminDataHelper(Emitter<AdminState> emit) async {
    final results = await Future.wait([
      repository.getAllOrders(),
      repository.getAllRestaurants(),
      repository.getAllMeals(),
      repository.getAllUsers(),
      repository.getDrivers(),
      repository.getSettings(),
      repository.getAllCategories(),
    ]);

    final ordersRes = results[0] as Either<Failure, List<OrderEntity>>;
    final restaurantsRes = results[1] as Either<Failure, List<RestaurantEntity>>;
    final mealsRes = results[2] as Either<Failure, List<MealEntity>>;
    final usersRes = results[3] as Either<Failure, List<UserEntity>>;
    final driversRes = results[4] as Either<Failure, List<Map<String, dynamic>>>;
    final settingsRes = results[5] as Either<Failure, Map<String, dynamic>>;
    final categoriesRes = results[6] as Either<Failure, List<CategoryEntity>>;

    String? errorMessage;
    List<OrderEntity>? orders;
    List<RestaurantEntity>? restaurants;
    List<MealEntity>? meals;
    List<UserEntity>? users;
    List<Map<String, dynamic>>? drivers;
    Map<String, dynamic>? settings;
    List<CategoryEntity>? categories;

    ordersRes.fold((f) => errorMessage = f.message, (v) => orders = v);
    restaurantsRes.fold((f) => errorMessage = f.message, (v) => restaurants = v);
    mealsRes.fold((f) => errorMessage = f.message, (v) => meals = v);
    usersRes.fold((f) => errorMessage = f.message, (v) => users = v);
    driversRes.fold((f) => errorMessage = f.message, (v) => drivers = v);
    settingsRes.fold((f) => errorMessage = f.message, (v) => settings = v);
    categoriesRes.fold((f) => errorMessage = f.message, (v) => categories = v);

    if (errorMessage != null) {
      emit(AdminError(errorMessage!));
    } else {
      // 1. Core Counts
      final totalOrders = orders!.length;
      final totalRestaurants = restaurants!.length;
      final totalMeals = meals!.length;
      final totalUsers = users!.length;
      final totalCategories = categories!.length;

      // 2. Revenue (sum of total for delivered orders)
      double totalRevenue = 0.0;
      for (var o in orders!) {
        if (o.status == OrderStatus.delivered) {
          totalRevenue += o.totalAmount;
        }
      }

      // 3. Recent Orders (sorted by date desc, cap at 10)
      final recentOrders = List<OrderEntity>.from(orders!)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentOrdersCapped = recentOrders.take(10).toList();

      // 4. Order Status Distribution Counts
      final Map<String, int> orderStatusCounts = {};
      for (var status in OrderStatus.values) {
        orderStatusCounts[status.name] = orders!.where((o) => o.status == status).length;
      }

      // 5. Top Selling Meals (by quantity sold in items)
      final Map<String, int> mealCounts = {};
      final Map<String, double> mealPrices = {};
      for (var o in orders!) {
        for (var item in o.items) {
          mealCounts[item.productName] = (mealCounts[item.productName] ?? 0) + item.quantity;
          mealPrices[item.productName] = item.unitPrice;
        }
      }
      final sortedMeals = mealCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final List<Map<String, dynamic>> topSellingMeals = sortedMeals.take(5).map((e) => {
        'name': e.key,
        'sales': e.value,
        'revenue': e.value * (mealPrices[e.key] ?? 0.0),
      }).toList();

      // 6. Top Performing Restaurants (by revenue from delivered orders)
      final Map<int, double> restRevenue = {};
      final Map<int, String> restNames = {};
      for (var o in orders!) {
        if (o.status == OrderStatus.delivered) {
          restRevenue[o.restaurant.id] = (restRevenue[o.restaurant.id] ?? 0.0) + o.totalAmount;
          restNames[o.restaurant.id] = o.restaurant.name;
        }
      }
      final sortedRest = restRevenue.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final List<Map<String, dynamic>> topPerformingRestaurants = sortedRest.take(5).map((e) => {
        'id': e.key,
        'name': restNames[e.key] ?? 'Unknown',
        'revenue': e.value,
      }).toList();

      // 7. Revenue By Day (grouping by date)
      final Map<String, double> revenueByDay = {};
      for (var o in orders!) {
        if (o.status == OrderStatus.delivered) {
          final day = "${o.createdAt.year}-${o.createdAt.month.toString().padLeft(2, '0')}-${o.createdAt.day.toString().padLeft(2, '0')}";
          revenueByDay[day] = (revenueByDay[day] ?? 0.0) + o.totalAmount;
        }
      }

      final loadedState = AdminLoaded(
        orders: orders!,
        restaurants: restaurants!,
        meals: meals!,
        categories: categories!,
        users: users!,
        drivers: drivers!,
        settings: settings!,
        totalOrders: totalOrders,
        totalRestaurants: totalRestaurants,
        totalMeals: totalMeals,
        totalCategories: totalCategories,
        totalUsers: totalUsers,
        totalRevenue: totalRevenue,
        recentOrders: recentOrdersCapped,
        orderStatusCounts: orderStatusCounts,
        topSellingMeals: topSellingMeals,
        topPerformingRestaurants: topPerformingRestaurants,
        revenueByDay: revenueByDay,
      );
      _lastLoadedState = loadedState;
      emit(loadedState);
    }
  }
}
