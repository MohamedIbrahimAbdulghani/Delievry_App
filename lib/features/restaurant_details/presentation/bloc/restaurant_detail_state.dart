import 'package:equatable/equatable.dart';
import '../../domain/entities/restaurant_detail_entity.dart';

abstract class RestaurantDetailState extends Equatable {
  const RestaurantDetailState();

  @override
  List<Object?> get props => [];
}

class RestaurantDetailInitial extends RestaurantDetailState {}

class RestaurantDetailLoading extends RestaurantDetailState {}

class RestaurantDetailLoaded extends RestaurantDetailState {
  final RestaurantDetailEntity restaurant;
  final bool isFavorite;

  const RestaurantDetailLoaded({
    required this.restaurant,
    this.isFavorite = false,
  });

  RestaurantDetailLoaded copyWith({
    RestaurantDetailEntity? restaurant,
    bool? isFavorite,
  }) {
    return RestaurantDetailLoaded(
      restaurant: restaurant ?? this.restaurant,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [restaurant, isFavorite];
}

class RestaurantDetailError extends RestaurantDetailState {
  final String message;

  const RestaurantDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
