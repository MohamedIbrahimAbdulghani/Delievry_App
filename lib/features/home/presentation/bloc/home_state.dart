import 'package:equatable/equatable.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/restaurant_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<BannerEntity> banners;
  final List<CategoryEntity> categories;
  final List<RestaurantEntity> restaurants;
  final List<MealEntity> popularMeals;
  final bool hasReachedMaxRestaurants;
  final bool hasReachedMaxMeals;
  final String selectedCategoryId;

  const HomeLoaded({
    required this.banners,
    required this.categories,
    required this.restaurants,
    required this.popularMeals,
    this.hasReachedMaxRestaurants = false,
    this.hasReachedMaxMeals = false,
    this.selectedCategoryId = 'All',
  });

  HomeLoaded copyWith({
    List<BannerEntity>? banners,
    List<CategoryEntity>? categories,
    List<RestaurantEntity>? restaurants,
    List<MealEntity>? popularMeals,
    bool? hasReachedMaxRestaurants,
    bool? hasReachedMaxMeals,
    String? selectedCategoryId,
  }) {
    return HomeLoaded(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      restaurants: restaurants ?? this.restaurants,
      popularMeals: popularMeals ?? this.popularMeals,
      hasReachedMaxRestaurants: hasReachedMaxRestaurants ?? this.hasReachedMaxRestaurants,
      hasReachedMaxMeals: hasReachedMaxMeals ?? this.hasReachedMaxMeals,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [
        banners,
        categories,
        restaurants,
        popularMeals,
        hasReachedMaxRestaurants,
        hasReachedMaxMeals,
        selectedCategoryId,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
