import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../home/data/models/restaurant_model.dart';
import '../../../home/data/models/meal_model.dart';
import '../../../home/data/models/category_model.dart';
import '../../../orders/data/models/order_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel> updateOrderStatus(int orderId, String status);

  Future<List<RestaurantModel>> getAllRestaurants();
  Future<RestaurantModel> createRestaurant(Map<String, dynamic> data);
  Future<RestaurantModel> updateRestaurant(int id, Map<String, dynamic> data);
  Future<void> deleteRestaurant(int id);

  Future<List<MealModel>> getAllMeals();
  Future<MealModel> createMeal(Map<String, dynamic> data);
  Future<MealModel> updateMeal(int id, Map<String, dynamic> data);
  Future<void> deleteMeal(int id);

  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel> createCategory(Map<String, dynamic> data);
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data);
  Future<void> deleteCategory(String id);

  Future<List<UserModel>> getAllUsers();
  Future<UserModel> createUser(Map<String, dynamic> data);
  Future<UserModel> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
  Future<OrderModel> assignDriver(int orderId, int driverId);

  // Drivers mock storage
  Future<List<Map<String, dynamic>>> getDrivers();
  Future<void> saveDrivers(List<Map<String, dynamic>> drivers);

  // Settings mock storage
  Future<Map<String, dynamic>> getSettings();
  Future<void> saveSettings(Map<String, dynamic> settings);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioClient dioClient;

  AdminRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await dioClient.get('/orders', queryParameters: {'per_page': 100});
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List list = data != null ? (data['items'] ?? []) : [];
        return list.map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await dioClient.post(
        '/orders/$orderId/status',
        data: {'status': status, '_method': 'PATCH'}, // Laravel patch method emulation
      );
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update order status');
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<List<RestaurantModel>> getAllRestaurants() async {
    try {
      final response = await dioClient.get('/restaurants', queryParameters: {'per_page': 100});
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List list = data != null ? (data['items'] ?? []) : [];
        return list.map((json) => RestaurantModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw Exception('Failed to load restaurants');
    } catch (e) {
      throw Exception('Failed to load restaurants: $e');
    }
  }

  @override
  Future<RestaurantModel> createRestaurant(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post('/restaurants', data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return RestaurantModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create restaurant');
    } catch (e) {
      throw Exception('Failed to create restaurant: $e');
    }
  }

  @override
  Future<RestaurantModel> updateRestaurant(int id, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        '/restaurants/$id',
        data: data,
      );
      if (response.statusCode == 200) {
        return RestaurantModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update restaurant');
    } catch (e) {
      throw Exception('Failed to update restaurant: $e');
    }
  }

  @override
  Future<void> deleteRestaurant(int id) async {
    try {
      final response = await dioClient.delete('/restaurants/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete restaurant');
      }
    } catch (e) {
      throw Exception('Failed to delete restaurant: $e');
    }
  }

  @override
  Future<List<MealModel>> getAllMeals() async {
    try {
      final response = await dioClient.get('/products', queryParameters: {'per_page': 100});
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List list = data != null ? (data['items'] ?? []) : [];
        return list.map((json) => MealModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw Exception('Failed to load meals');
    } catch (e) {
      throw Exception('Failed to load meals: $e');
    }
  }

  @override
  Future<MealModel> createMeal(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post('/products', data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return MealModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create meal');
    } catch (e) {
      throw Exception('Failed to create meal: $e');
    }
  }

  @override
  Future<MealModel> updateMeal(int id, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        '/products/$id',
        data: data,
      );
      if (response.statusCode == 200) {
        return MealModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update meal');
    } catch (e) {
      throw Exception('Failed to update meal: $e');
    }
  }

  @override
  Future<void> deleteMeal(int id) async {
    try {
      final response = await dioClient.delete('/products/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete meal');
      }
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('admin_categories');
    if (data != null) {
      final List list = jsonDecode(data);
      return list.map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json))).toList();
    }
    // Pre-seeded default categories
    final defaultCategories = [
      const CategoryModel(id: 'Broast', name: 'Broast', imageUrl: 'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=600', isVisible: true, restaurantIds: [1, 2, 3]),
      const CategoryModel(id: 'Burgers', name: 'Burgers', imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600', isVisible: true, restaurantIds: [1, 2, 3]),
      const CategoryModel(id: 'Pizza', name: 'Pizza', imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600', isVisible: true, restaurantIds: [1, 2]),
      const CategoryModel(id: 'Pasta', name: 'Pasta', imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600', isVisible: true, restaurantIds: [2, 3]),
      const CategoryModel(id: 'Sides', name: 'Sides', imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600', isVisible: true, restaurantIds: [3]),
    ];
    await prefs.setString('admin_categories', jsonEncode(defaultCategories.map((c) => c.toJson()).toList()));
    return defaultCategories;
  }

  @override
  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    final categories = await getAllCategories();
    final id = data['name'].toString().toLowerCase().replaceAll(' ', '-');
    final newCat = CategoryModel(
      id: id,
      name: data['name'],
      imageUrl: data['image_url'],
      isVisible: data['is_visible'] ?? true,
      restaurantIds: (data['restaurant_ids'] as List?)?.map((e) => int.parse(e.toString())).toList() ?? const [],
    );
    categories.add(newCat);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_categories', jsonEncode(categories.map((c) => c.toJson()).toList()));
    return newCat;
  }

  @override
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    final categories = await getAllCategories();
    final index = categories.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('Category not found');
    }
    final updatedCat = CategoryModel(
      id: id,
      name: data['name'] ?? categories[index].name,
      imageUrl: data['image_url'] ?? categories[index].imageUrl,
      isVisible: data['is_visible'] ?? categories[index].isVisible,
      restaurantIds: data.containsKey('restaurant_ids')
          ? (data['restaurant_ids'] as List).map((e) => int.parse(e.toString())).toList()
          : categories[index].restaurantIds,
    );
    categories[index] = updatedCat;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_categories', jsonEncode(categories.map((c) => c.toJson()).toList()));
    return updatedCat;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final categories = await getAllCategories();
    categories.removeWhere((c) => c.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_categories', jsonEncode(categories.map((c) => c.toJson()).toList()));
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await dioClient.get('/users', queryParameters: {'per_page': 100});
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List list = data != null ? (data['items'] ?? []) : [];
        return list.map((json) => UserModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw Exception('Failed to load users');
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post('/users', data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create user');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        '/users/$id',
        data: data,
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update user');
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      final response = await dioClient.delete('/users/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<OrderModel> assignDriver(int orderId, int driverId) async {
    try {
      final response = await dioClient.post(
        '/orders/$orderId/assign',
        data: {'driver_id': driverId, '_method': 'PATCH'},
      );
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to assign driver');
    } catch (e) {
      throw Exception('Failed to assign driver: $e');
    }
  }

  // Drivers mock storage
  @override
  Future<List<Map<String, dynamic>>> getDrivers() async {
    try {
      final users = await getAllUsers();
      final drivers = users.where((u) => u.role == 'delivery').map((u) => {
        'id': u.id.toString(),
        'name': u.name,
        'phone': '+15550001',
        'status': u.isOnline ? 'online' : 'offline',
        'is_blocked': u.isBlocked,
      }).toList();
      return drivers;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('admin_drivers');
      if (data != null) {
        final List list = jsonDecode(data);
        return list.cast<Map<String, dynamic>>();
      }
      final initialDrivers = [
        {'id': '1', 'name': 'John Doe', 'phone': '+15550001', 'status': 'available', 'is_blocked': false},
        {'id': '2', 'name': 'Sam Smith', 'phone': '+15550002', 'status': 'busy', 'is_blocked': false},
      ];
      await prefs.setString('admin_drivers', jsonEncode(initialDrivers));
      return initialDrivers;
    }
  }

  @override
  Future<void> saveDrivers(List<Map<String, dynamic>> drivers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_drivers', jsonEncode(drivers));
  }

  // Settings mock storage
  @override
  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('admin_settings');
    if (data != null) {
      return Map<String, dynamic>.from(jsonDecode(data));
    }
    // Return default settings
    return {
      'delivery_fee': 2.50,
      'tax_rate': 0.15,
      'currency': 'USD',
      'app_name': 'Delivry App',
      'promo_banners': [
        'Get 50% off on your first order',
        'Try our new Italian Pizza!',
      ]
    };
  }

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_settings', jsonEncode(settings));
  }
}
