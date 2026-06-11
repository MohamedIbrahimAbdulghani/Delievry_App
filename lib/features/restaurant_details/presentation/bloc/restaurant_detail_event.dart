import 'package:equatable/equatable.dart';

abstract class RestaurantDetailEvent extends Equatable {
  const RestaurantDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchRestaurantDetails extends RestaurantDetailEvent {
  final int id;
  const FetchRestaurantDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleFavorite extends RestaurantDetailEvent {
  final int id;
  const ToggleFavorite(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateRestaurantFavoriteStatus extends RestaurantDetailEvent {
  final int restaurantId;
  final bool isFavorite;
  const UpdateRestaurantFavoriteStatus(this.restaurantId, this.isFavorite);

  @override
  List<Object?> get props => [restaurantId, isFavorite];
}
