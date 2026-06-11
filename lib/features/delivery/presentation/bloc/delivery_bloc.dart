import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/usecases/get_assigned_orders_usecase.dart';
import '../../domain/usecases/update_delivery_status_usecase.dart';
import '../../domain/usecases/update_driver_location_usecase.dart';
import '../../domain/usecases/toggle_availability_usecase.dart';
import '../../domain/usecases/get_driver_earnings_usecase.dart';
import '../../domain/usecases/get_delivery_history_usecase.dart';
import 'delivery_event.dart';
import 'delivery_state.dart';

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  final GetAssignedOrdersUseCase getAssignedOrdersUseCase;
  final UpdateDeliveryStatusUseCase updateDeliveryStatusUseCase;
  final UpdateDriverLocationUseCase updateDriverLocationUseCase;
  final ToggleAvailabilityUseCase toggleAvailabilityUseCase;
  final GetDriverEarningsUseCase getDriverEarningsUseCase;
  final GetDeliveryHistoryUseCase getDeliveryHistoryUseCase;
  final SessionManager sessionManager;

  DeliveryLoaded? _lastLoadedState;

  DeliveryBloc({
    required this.getAssignedOrdersUseCase,
    required this.updateDeliveryStatusUseCase,
    required this.updateDriverLocationUseCase,
    required this.toggleAvailabilityUseCase,
    required this.getDriverEarningsUseCase,
    required this.getDeliveryHistoryUseCase,
    required this.sessionManager,
  }) : super(DeliveryInitial()) {
    on<FetchAssignedOrders>(_onFetchAssignedOrders);
    on<UpdateDeliveryStatus>(_onUpdateDeliveryStatus);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);
    on<ToggleAvailability>(_onToggleAvailability);
    on<FetchDriverEarnings>(_onFetchDriverEarnings);
    on<FetchDeliveryHistory>(_onFetchDeliveryHistory);
  }

  Future<void> _fetchDataHelper(Emitter<DeliveryState> emit) async {
    final driver = sessionManager.currentUser;
    if (driver == null) {
      emit(const DeliveryError('Driver session not found.'));
      return;
    }

    final results = await Future.wait([
      getAssignedOrdersUseCase(),
      getDriverEarningsUseCase(),
      getDeliveryHistoryUseCase(),
    ]);

    final ordersRes = results[0] as Either<Failure, List<OrderEntity>>;
    final earningsRes = results[1] as Either<Failure, Map<String, dynamic>>;
    final historyRes = results[2] as Either<Failure, List<OrderEntity>>;

    String? errorMessage;
    List<OrderEntity>? orders;
    Map<String, dynamic>? earnings;
    List<OrderEntity>? history;

    ordersRes.fold((f) => errorMessage = f.message, (v) => orders = v);
    earningsRes.fold((f) => errorMessage = f.message, (v) => earnings = v);
    historyRes.fold((f) => errorMessage = f.message, (v) => history = v);

    if (errorMessage != null) {
      emit(DeliveryError(errorMessage!));
    } else {
      final loadedState = DeliveryLoaded(
        assignedOrders: orders!,
        driver: driver,
        earnings: earnings!,
        history: history!,
      );
      _lastLoadedState = loadedState;
      emit(loadedState);
    }
  }

  Future<void> _onFetchAssignedOrders(FetchAssignedOrders event, Emitter<DeliveryState> emit) async {
    emit(DeliveryLoading());
    await _fetchDataHelper(emit);
  }

  Future<void> _onUpdateDeliveryStatus(UpdateDeliveryStatus event, Emitter<DeliveryState> emit) async {
    final result = await updateDeliveryStatusUseCase(event.orderId, event.status);
    await result.fold(
      (failure) async {
        emit(DeliveryError(failure.message));
        if (_lastLoadedState != null) emit(_lastLoadedState!);
      },
      (order) async {
        emit(DeliveryActionSuccess('Status updated to ${event.status}'));
        await _fetchDataHelper(emit);
      },
    );
  }

  Future<void> _onUpdateDriverLocation(UpdateDriverLocation event, Emitter<DeliveryState> emit) async {
    final result = await updateDriverLocationUseCase(event.orderId, event.latitude, event.longitude);
    await result.fold(
      (failure) async {
        emit(DeliveryError(failure.message));
        if (_lastLoadedState != null) emit(_lastLoadedState!);
      },
      (order) async {
        emit(const DeliveryActionSuccess('Location updated successfully'));
        await _fetchDataHelper(emit);
      },
    );
  }

  Future<void> _onToggleAvailability(ToggleAvailability event, Emitter<DeliveryState> emit) async {
    final result = await toggleAvailabilityUseCase(event.isOnline);
    await result.fold(
      (failure) async {
        emit(DeliveryError(failure.message));
        if (_lastLoadedState != null) emit(_lastLoadedState!);
      },
      (user) async {
        sessionManager.setCurrentUser(user);
        emit(DeliveryActionSuccess(event.isOnline ? 'You are now Online' : 'You are now Offline'));
        await _fetchDataHelper(emit);
      },
    );
  }

  Future<void> _onFetchDriverEarnings(FetchDriverEarnings event, Emitter<DeliveryState> emit) async {
    emit(DeliveryLoading());
    await _fetchDataHelper(emit);
  }

  Future<void> _onFetchDeliveryHistory(FetchDeliveryHistory event, Emitter<DeliveryState> emit) async {
    emit(DeliveryLoading());
    await _fetchDataHelper(emit);
  }
}
