import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_restaurant_details_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import 'restaurant_detail_event.dart';
import 'restaurant_detail_state.dart';

class RestaurantDetailBloc extends Bloc<RestaurantDetailEvent, RestaurantDetailState> {
  final GetRestaurantDetailsUseCase getRestaurantDetailsUseCase;
  final ToggleFavoriteRestaurantUseCase toggleFavoriteUseCase;

  RestaurantDetailBloc({
    required this.getRestaurantDetailsUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(RestaurantDetailInitial()) {
    on<FetchRestaurantDetails>(_onFetchRestaurantDetails);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onFetchRestaurantDetails(
    FetchRestaurantDetails event,
    Emitter<RestaurantDetailState> emit,
  ) async {
    emit(RestaurantDetailLoading());
    final result = await getRestaurantDetailsUseCase(event.id);
    result.fold(
      (failure) => emit(RestaurantDetailError(failure.message)),
      (restaurant) => emit(RestaurantDetailLoaded(restaurant: restaurant)),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<RestaurantDetailState> emit,
  ) async {
    debugPrint('ToggleFavorite event triggered for id: ${event.id}');
    if (state is RestaurantDetailLoaded) {
      final currentState = state as RestaurantDetailLoaded;
      debugPrint('Current isFavorite: ${currentState.isFavorite}');
      
      final result = await toggleFavoriteUseCase(event.id);
      result.fold(
        (failure) => debugPrint('ToggleFavorite failed: ${failure.message}'),
        (isFavorite) {
          debugPrint('ToggleFavorite success, new isFavorite: $isFavorite');
          emit(currentState.copyWith(isFavorite: isFavorite));
        },
      );
    } else {
       debugPrint('State is not RestaurantDetailLoaded');
    }
  }
}
