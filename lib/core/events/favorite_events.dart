import 'dart:async';

class FavoriteEvent {
  final int restaurantId;
  final bool isFavorite;

  const FavoriteEvent({
    required this.restaurantId,
    required this.isFavorite,
  });
}

class FavoriteEventBus {
  final StreamController<FavoriteEvent> _controller = StreamController<FavoriteEvent>.broadcast();

  Stream<FavoriteEvent> get stream => _controller.stream;

  void fire(FavoriteEvent event) {
    _controller.add(event);
  }
}
