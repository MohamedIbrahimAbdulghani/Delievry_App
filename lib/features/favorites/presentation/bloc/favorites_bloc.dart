import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/favorites_usecases.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
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
      (success) => add(FetchFavorites()),
    );
  }
}
