import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;

  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
  }) : super(NotificationsInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
  }

  Future<void> _onFetchNotifications(FetchNotifications event, Emitter<NotificationsState> emit) async {
    emit(NotificationsLoading());
    final result = await getNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> _onMarkAsRead(MarkAsReadEvent event, Emitter<NotificationsState> emit) async {
    final result = await markNotificationAsReadUseCase(event.notificationId);
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (_) {
        // Refresh list
        add(FetchNotifications());
      },
    );
  }
}
