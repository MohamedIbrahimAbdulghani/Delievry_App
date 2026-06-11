import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/events/favorite_events.dart';
import '../../domain/usecases/favorites_usecases.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final FavoriteEventBus favoriteEventBus;
  StreamSubscription<FavoriteEvent>? _favoriteSubscription;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
    required this.favoriteEventBus,
  }) : super(FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);

    _favoriteSubscription = favoriteEventBus.stream.listen((event) {
      add(FetchFavorites());
    });
  }

  @override
  Future<void> close() {
    _favoriteSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetchFavorites(FetchFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    final result = await getFavoritesUseCase();
    result.fold(
      (failure) => emit(FavoritesError(failure.toString())),
      (favorites) => emit(FavoritesLoaded(favorites)),
    );
  }

  Future<void> _onToggleFavorite(ToggleFavoriteEvent event, Emitter<FavoritesState> emit) async {
    final result = await toggleFavoriteUseCase(event.id, event.isFavorite);
    result.fold(
      (failure) => emit(FavoritesError(failure.toString())),
      (success) {
        favoriteEventBus.fire(FavoriteEvent(restaurantId: int.parse(event.id), isFavorite: event.isFavorite));
      },
    );
  }
}
