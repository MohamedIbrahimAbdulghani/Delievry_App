import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/events/favorite_events.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/usecases/get_banners_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_popular_meals_usecase.dart';
import '../../domain/usecases/get_restaurants_usecase.dart';
import '../../../restaurant_details/domain/usecases/toggle_favorite_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetBannersUseCase getBannersUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetRestaurantsUseCase getRestaurantsUseCase;
  final GetPopularMealsUseCase getPopularMealsUseCase;
  final ToggleFavoriteRestaurantUseCase toggleFavoriteUseCase;
  final FavoriteEventBus favoriteEventBus;
  StreamSubscription<FavoriteEvent>? _favoriteSubscription;

  int _restaurantPage = 1;
  int _mealPage = 1;
  String? _currentCategoryId;
  String? _currentQuery;

  List<BannerEntity> _allBanners = [];
  List<CategoryEntity> _allCategories = [];
  List<RestaurantEntity> _allRestaurants = [];
  List<MealEntity> _allMeals = [];
  bool _hasReachedMaxRestaurants = false;
  bool _hasReachedMaxMeals = false;

  HomeBloc({
    required this.getBannersUseCase,
    required this.getCategoriesUseCase,
    required this.getRestaurantsUseCase,
    required this.getPopularMealsUseCase,
    required this.toggleFavoriteUseCase,
    required this.favoriteEventBus,
  }) : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<FetchMoreRestaurants>(_onFetchMoreRestaurants);
    on<FetchMoreMeals>(_onFetchMoreMeals);
    on<FilterByCategory>(_onFilterByCategory);
    on<SearchRequested>(_onSearchRequested);
    on<ToggleFavoriteRestaurant>(_onToggleFavoriteRestaurant);
    on<UpdateFavoriteStatus>(_onUpdateFavoriteStatus);

    _favoriteSubscription = favoriteEventBus.stream.listen((event) {
      add(UpdateFavoriteStatus(event.restaurantId, event.isFavorite));
    });
  }

  void _onUpdateFavoriteStatus(UpdateFavoriteStatus event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      _allRestaurants = _allRestaurants.map((restaurant) {
        if (restaurant.id == event.restaurantId) {
          return restaurant.copyWith(isFavorite: event.isFavorite);
        }
        return restaurant;
      }).toList();
      _emitFilteredState(emit);
    }
  }

  @override
  Future<void> close() {
    _favoriteSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetchHomeData(FetchHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefreshHomeData(RefreshHomeData event, Emitter<HomeState> emit) async {
    _restaurantPage = 1;
    _mealPage = 1;
    _allRestaurants.clear();
    _allMeals.clear();
    _allBanners.clear();
    _allCategories.clear();
    _hasReachedMaxRestaurants = false;
    _hasReachedMaxMeals = false;
    emit(HomeLoading());
    await _fetchData(emit);
  }

  Future<void> _onFilterByCategory(FilterByCategory event, Emitter<HomeState> emit) async {
    // Toggle logic: if same category is clicked again, reset to 'All'
    if (_currentCategoryId == event.categoryId) {
      _currentCategoryId = 'All';
    } else {
      _currentCategoryId = event.categoryId;
    }
    
    // Clear search query when filtering by category
    _currentQuery = null;
    
    // Reset pagination pages for the new category
    _restaurantPage = 1;
    _mealPage = 1;
    _allRestaurants.clear();
    _allMeals.clear();
    _hasReachedMaxRestaurants = false;
    _hasReachedMaxMeals = false;

    emit(HomeLoading());
    await _fetchData(emit);
  }

  Future<void> _onSearchRequested(SearchRequested event, Emitter<HomeState> emit) async {
    _currentQuery = event.query;
    
    if (_allRestaurants.isEmpty && _allMeals.isEmpty) {
      emit(HomeLoading());
      await _fetchData(emit);
    } else {
      _emitFilteredState(emit);
    }
  }

  Future<void> _fetchData(Emitter<HomeState> emit) async {
    final categoryId = _currentCategoryId == 'All' ? null : _currentCategoryId;
    final query = _currentQuery;

    final results = await Future.wait([
      getBannersUseCase(),
      getCategoriesUseCase(),
      getRestaurantsUseCase(
        page: 1,
        categoryId: categoryId,
        query: query,
      ),
      getPopularMealsUseCase(
        page: 1,
        categoryId: categoryId,
        query: query,
      ),
    ]);

    final bannersResult = results[0];
    final categoriesResult = results[1];
    final restaurantsResult = results[2];
    final mealsResult = results[3];

    String? errorMessage;
    List? banners, categories, restaurants, meals;
    
    bannersResult.fold((f) => errorMessage = f.message, (v) => banners = v as List);
    categoriesResult.fold((f) => errorMessage = f.message, (v) => categories = v as List);
    restaurantsResult.fold((f) => errorMessage = f.message, (v) => restaurants = v as List);
    mealsResult.fold((f) => errorMessage = f.message, (v) => meals = v as List);

    if (errorMessage != null) {
      emit(HomeError(errorMessage!));
    } else {
      _allBanners = banners!.cast<BannerEntity>();
      _allCategories = categories!.cast<CategoryEntity>();
      _allRestaurants = restaurants!.cast<RestaurantEntity>();
      _allMeals = meals!.cast<MealEntity>();
      _hasReachedMaxRestaurants = restaurants!.length < 10;
      _hasReachedMaxMeals = meals!.length < 10;

      _emitFilteredState(emit);
    }
  }

  void _emitFilteredState(Emitter<HomeState> emit) {
    final categoryId = _currentCategoryId ?? 'All';
    final query = _currentQuery ?? '';

    // 1. Filter restaurants by category (API-based, no client-side filtering needed)
    List<RestaurantEntity> filteredRestaurants = _allRestaurants;

    // 2. Filter meals by category and search query
    List<MealEntity> filteredMeals = _allMeals;
    
    // Apply category filter if active
    if (categoryId != 'All') {
      filteredMeals = filteredMeals.where((meal) =>
          meal.category.toLowerCase() == categoryId.toLowerCase()).toList();
    }
    
    // Apply search query filter if active
    if (query.isNotEmpty) {
      filteredMeals = filteredMeals.where((meal) => _matchesSearch(meal, query)).toList();
    }

    emit(HomeLoaded(
      banners: _allBanners,
      categories: _allCategories,
      restaurants: filteredRestaurants,
      popularMeals: filteredMeals,
      hasReachedMaxRestaurants: _hasReachedMaxRestaurants,
      hasReachedMaxMeals: _hasReachedMaxMeals,
      selectedCategoryId: categoryId,
    ));
  }

  bool _matchesSearch(MealEntity meal, String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    final name = meal.name.toLowerCase();
    final description = meal.description.toLowerCase();

    // Direct match
    if (name.contains(cleanQuery) || description.contains(cleanQuery)) {
      return true;
    }

    // Arabic keyword mapping to English
    final Map<String, List<String>> arabicToEnglish = {
      'بيتزا': ['pizza'],
      'برجر': ['burger'],
      'بورجر': ['burger'],
      'بروست': ['broast'],
      'باستا': ['pasta', 'carbonara', 'fettuccine'],
      'مكرونة': ['pasta', 'carbonara', 'fettuccine'],
      'معكرونة': ['pasta', 'carbonara', 'fettuccine'],
      'بطاطس': ['fries'],
      'فرايز': ['fries'],
      'تندر': ['tender'],
      'تندرز': ['tender'],
      'دجاج': ['chicken', 'broast', 'tender'],
      'لحم': ['beef', 'burger'],
      'جبنة': ['cheese'],
      'عائلي': ['family', 'bucket'],
    };

    // English keyword mapping to Arabic
    final Map<String, List<String>> englishToArabic = {
      'pizza': ['بيتزا'],
      'burger': ['برجر', 'بورجر'],
      'broast': ['بروست'],
      'pasta': ['باستا', 'مكرونة', 'معكرونة'],
      'carbonara': ['باستا', 'مكرونة', 'معكرونة'],
      'fettuccine': ['باستا', 'مكرونة', 'معكرونة'],
      'fries': ['بطاطس', 'فرايز'],
      'tender': ['تندر', 'تندرز'],
      'tenders': ['تندر', 'تندرز'],
      'chicken': ['دجاج'],
      'beef': ['لحم'],
      'cheese': ['جبنة'],
      'family': ['عائلي'],
      'bucket': ['عائلي'],
    };

    for (final entry in arabicToEnglish.entries) {
      if (cleanQuery.contains(entry.key) || entry.key.contains(cleanQuery)) {
        for (final englishTerm in entry.value) {
          if (name.contains(englishTerm) || description.contains(englishTerm)) {
            return true;
          }
        }
      }
    }

    for (final entry in englishToArabic.entries) {
      if (cleanQuery.contains(entry.key) || entry.key.contains(cleanQuery)) {
        for (final arabicTerm in entry.value) {
          if (name.contains(arabicTerm) || description.contains(arabicTerm)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  Future<void> _onFetchMoreRestaurants(FetchMoreRestaurants event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      if (_hasReachedMaxRestaurants) return;

      _restaurantPage++;
      final categoryId = _currentCategoryId == 'All' ? null : _currentCategoryId;
      final result = await getRestaurantsUseCase(
        page: _restaurantPage,
        categoryId: categoryId,
        query: _currentQuery,
      );

      result.fold(
        (failure) => null,
        (newRestaurants) {
          if (newRestaurants.isEmpty) {
            _hasReachedMaxRestaurants = true;
            _emitFilteredState(emit);
          } else {
            _allRestaurants.addAll(newRestaurants);
            if (newRestaurants.length < 10) {
              _hasReachedMaxRestaurants = true;
            }
            _emitFilteredState(emit);
          }
        },
      );
    }
  }

  Future<void> _onFetchMoreMeals(FetchMoreMeals event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      if (_hasReachedMaxMeals) return;

      _mealPage++;
      final categoryId = _currentCategoryId == 'All' ? null : _currentCategoryId;
      final result = await getPopularMealsUseCase(
        page: _mealPage,
        categoryId: categoryId,
        query: _currentQuery,
      );

      result.fold(
        (failure) => null,
        (newMeals) {
          if (newMeals.isEmpty) {
            _hasReachedMaxMeals = true;
            _emitFilteredState(emit);
          } else {
            _allMeals.addAll(newMeals);
            if (newMeals.length < 10) {
              _hasReachedMaxMeals = true;
            }
            _emitFilteredState(emit);
          }
        },
      );
    }
  }

  Future<void> _onToggleFavoriteRestaurant(ToggleFavoriteRestaurant event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      // Optimistic update
      _allRestaurants = _allRestaurants.map((restaurant) {
        if (restaurant.id == event.restaurantId) {
          return restaurant.copyWith(isFavorite: !restaurant.isFavorite);
        }
        return restaurant;
      }).toList();
      
      _emitFilteredState(emit);

      final result = await toggleFavoriteUseCase(event.restaurantId);
      
      result.fold(
        (failure) {
          // Revert optimistic update on failure
          _allRestaurants = _allRestaurants.map((restaurant) {
            if (restaurant.id == event.restaurantId) {
              return restaurant.copyWith(isFavorite: !restaurant.isFavorite);
            }
            return restaurant;
          }).toList();
          _emitFilteredState(emit);
        },
        (isFavorite) {
          favoriteEventBus.fire(FavoriteEvent(restaurantId: event.restaurantId, isFavorite: isFavorite));
        },
      );
    }
  }
}
