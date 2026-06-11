import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/meal_entity.dart';
import '../../../home/domain/entities/category_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<OrderEntity> orders;
  final List<RestaurantEntity> restaurants;
  final List<MealEntity> meals;
  final List<CategoryEntity> categories;
  final List<UserEntity> users;
  final List<Map<String, dynamic>> drivers;
  final Map<String, dynamic> settings;

  // Computed Analytics
  final int totalOrders;
  final int totalRestaurants;
  final int totalMeals;
  final int totalCategories;
  final int totalUsers;
  final double totalRevenue;
  final List<OrderEntity> recentOrders;
  final Map<String, int> orderStatusCounts;
  final List<Map<String, dynamic>> topSellingMeals;
  final List<Map<String, dynamic>> topPerformingRestaurants;
  final Map<String, double> revenueByDay; // For charting

  const AdminLoaded({
    required this.orders,
    required this.restaurants,
    required this.meals,
    required this.categories,
    required this.users,
    required this.drivers,
    required this.settings,
    required this.totalOrders,
    required this.totalRestaurants,
    required this.totalMeals,
    required this.totalCategories,
    required this.totalUsers,
    required this.totalRevenue,
    required this.recentOrders,
    required this.orderStatusCounts,
    required this.topSellingMeals,
    required this.topPerformingRestaurants,
    required this.revenueByDay,
  });

  AdminLoaded copyWith({
    List<OrderEntity>? orders,
    List<RestaurantEntity>? restaurants,
    List<MealEntity>? meals,
    List<CategoryEntity>? categories,
    List<UserEntity>? users,
    List<Map<String, dynamic>>? drivers,
    Map<String, dynamic>? settings,
    int? totalOrders,
    int? totalRestaurants,
    int? totalMeals,
    int? totalCategories,
    int? totalUsers,
    double? totalRevenue,
    List<OrderEntity>? recentOrders,
    Map<String, int>? orderStatusCounts,
    List<Map<String, dynamic>>? topSellingMeals,
    List<Map<String, dynamic>>? topPerformingRestaurants,
    Map<String, double>? revenueByDay,
  }) {
    return AdminLoaded(
      orders: orders ?? this.orders,
      restaurants: restaurants ?? this.restaurants,
      meals: meals ?? this.meals,
      categories: categories ?? this.categories,
      users: users ?? this.users,
      drivers: drivers ?? this.drivers,
      settings: settings ?? this.settings,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRestaurants: totalRestaurants ?? this.totalRestaurants,
      totalMeals: totalMeals ?? this.totalMeals,
      totalCategories: totalCategories ?? this.totalCategories,
      totalUsers: totalUsers ?? this.totalUsers,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      recentOrders: recentOrders ?? this.recentOrders,
      orderStatusCounts: orderStatusCounts ?? this.orderStatusCounts,
      topSellingMeals: topSellingMeals ?? this.topSellingMeals,
      topPerformingRestaurants: topPerformingRestaurants ?? this.topPerformingRestaurants,
      revenueByDay: revenueByDay ?? this.revenueByDay,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        restaurants,
        meals,
        categories,
        users,
        drivers,
        settings,
        totalOrders,
        totalRestaurants,
        totalMeals,
        totalCategories,
        totalUsers,
        totalRevenue,
        recentOrders,
        orderStatusCounts,
        topSellingMeals,
        topPerformingRestaurants,
        revenueByDay,
      ];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminActionFailure extends AdminState {
  final String message;

  const AdminActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
