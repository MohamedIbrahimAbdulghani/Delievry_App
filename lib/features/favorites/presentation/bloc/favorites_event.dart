import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object> get props => [];
}

class FetchFavorites extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String id;
  final bool isFavorite;

  const ToggleFavoriteEvent(this.id, this.isFavorite);
  @override
  List<Object> get props => [id, isFavorite];
}
