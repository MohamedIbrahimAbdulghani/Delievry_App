import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/meal_model.dart';
import '../models/restaurant_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<BannerModel>> getBanners();
  Future<List<CategoryModel>> getCategories();
  Future<List<RestaurantModel>> getRestaurants({
    int page = 1,
    String? categoryId,
    String? query,
  });
  Future<List<MealModel>> getPopularMeals({
    int page = 1,
    String? categoryId,
    String? query,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;

  HomeRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<BannerModel>> getBanners() async {
    // Mocking banners as they are not in the backend
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const BannerModel(
        id: '1',
        imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=1000',
        title: 'Special Offer',
        description: 'Get 50% off on your first order',
      ),
      const BannerModel(
        id: '2',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=1000',
        title: 'New Pizza',
        description: 'Try our new Italian Pizza',
      ),
    ];
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('admin_categories');
      List<CategoryModel> categories = [];
      if (data != null) {
        final List list = jsonDecode(data);
        categories = list.map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json))).toList();
      } else {
        categories = [
          const CategoryModel(id: 'Broast', name: 'Broast', imageUrl: 'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=600', isVisible: true, restaurantIds: [1, 2, 3]),
          const CategoryModel(id: 'Burgers', name: 'Burgers', imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600', isVisible: true, restaurantIds: [1, 2, 3]),
          const CategoryModel(id: 'Pizza', name: 'Pizza', imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600', isVisible: true, restaurantIds: [1, 2]),
          const CategoryModel(id: 'Pasta', name: 'Pasta', imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600', isVisible: true, restaurantIds: [2, 3]),
          const CategoryModel(id: 'Sides', name: 'Sides', imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600', isVisible: true, restaurantIds: [3]),
        ];
        await prefs.setString('admin_categories', jsonEncode(categories.map((c) => c.toJson()).toList()));
      }

      final visibleCategories = categories.where((c) => c.isVisible).toList();
      return [
        const CategoryModel(id: 'All', name: 'All', imageUrl: null, isVisible: true, restaurantIds: []),
        ...visibleCategories,
      ];
    } catch (e) {
      debugPrint('Categories Fetch Error: $e');
      return [
        const CategoryModel(id: 'All', name: 'All', imageUrl: null, isVisible: true, restaurantIds: []),
      ];
    }
  }

  @override
  Future<List<RestaurantModel>> getRestaurants({
    int page = 1,
    String? categoryId,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (categoryId != null && categoryId != 'All' && categoryId != '1') {
        queryParams['filter[category]'] = categoryId;
      }
      if (query != null && query.isNotEmpty) queryParams['filter[name]'] = query;

      final response = await dioClient.get(
        ApiConstants.restaurants,
        queryParameters: queryParams,
      );

      debugPrint('Restaurants API Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null || data['items'] == null) {
          return [];
        }
        final List list = data['items'];
        final restaurants = list.map((json) => RestaurantModel.fromJson(json)).toList();

        // Client-side category restaurant filtering if categoryId is specific and not 'All'
        if (categoryId != null && categoryId != 'All') {
          final prefs = await SharedPreferences.getInstance();
          final categoryData = prefs.getString('admin_categories');
          if (categoryData != null) {
            final List catsList = jsonDecode(categoryData);
            final categories = catsList.map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json))).toList();
            final matchedCat = categories.cast<CategoryModel?>().firstWhere(
              (c) => c?.id == categoryId,
              orElse: () => null,
            );
            if (matchedCat != null && matchedCat.restaurantIds.isNotEmpty) {
              return restaurants.where((r) => matchedCat.restaurantIds.contains(r.id)).toList();
            }
          }
        }
        return restaurants;
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch restaurants');
      }
    } catch (e) {
      debugPrint('Restaurants API Error: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MealModel>> getPopularMeals({
    int page = 1,
    String? categoryId,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (categoryId != null && categoryId != 'All' && categoryId != '1') {
        queryParams['filter[category]'] = categoryId;
      }
      if (query != null && query.isNotEmpty) queryParams['filter[search]'] = query;

      final response = await dioClient.get(
        ApiConstants.products,
        queryParameters: queryParams,
      );

      debugPrint('Products API Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null || data['items'] == null) {
          return [];
        }
        final List list = data['items'];
        return list.map((json) => MealModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch products');
      }
    } catch (e) {
      debugPrint('Products API Error: $e');
      throw ServerException(e.toString());
    }
  }
}
