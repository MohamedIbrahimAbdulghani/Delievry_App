import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/order_usecases.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderDetailsUseCase getOrderDetailsUseCase;
  final ReorderUseCase reorderUseCase;

  OrdersBloc({
    required this.getOrdersUseCase,
    required this.getOrderDetailsUseCase,
    required this.reorderUseCase,
  }) : super(OrdersInitial()) {
    on<FetchOrders>(_onFetchOrders);
    on<FetchOrderDetails>(_onFetchOrderDetails);
    on<ReorderEvent>(_onReorder);
  }

  Future<void> _onFetchOrders(FetchOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    final result = await getOrdersUseCase();
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  Future<void> _onFetchOrderDetails(FetchOrderDetails event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    final result = await getOrderDetailsUseCase(event.id);
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (order) => emit(OrderDetailsLoaded(order)),
    );
  }

  Future<void> _onReorder(ReorderEvent event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    final result = await reorderUseCase(event.id);
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (success) => emit(ReorderSuccess()),
    );
  }
}
