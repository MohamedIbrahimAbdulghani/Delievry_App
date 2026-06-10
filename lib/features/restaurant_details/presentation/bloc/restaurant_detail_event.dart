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
