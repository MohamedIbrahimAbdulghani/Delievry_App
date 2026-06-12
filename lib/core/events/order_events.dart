import 'dart:async';

class OrderPlacedEvent {
  const OrderPlacedEvent();
}

class OrderEventBus {
  final StreamController<OrderPlacedEvent> _controller = StreamController<OrderPlacedEvent>.broadcast();

  Stream<OrderPlacedEvent> get stream => _controller.stream;

  void fire(OrderPlacedEvent event) {
    _controller.add(event);
  }
}
