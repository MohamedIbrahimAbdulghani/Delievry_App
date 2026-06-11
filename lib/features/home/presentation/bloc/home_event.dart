import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class FetchMoreRestaurants extends HomeEvent {}

class FetchMoreMeals extends HomeEvent {}

class FilterByCategory extends HomeEvent {
  final String categoryId;
  const FilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchRequested extends HomeEvent {
  final String query;
  const SearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleFavoriteRestaurant extends HomeEvent {
  final int restaurantId;
  const ToggleFavoriteRestaurant(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class UpdateFavoriteStatus extends HomeEvent {
  final int restaurantId;
  final bool isFavorite;
  const UpdateFavoriteStatus(this.restaurantId, this.isFavorite);

  @override
  List<Object?> get props => [restaurantId, isFavorite];
}
