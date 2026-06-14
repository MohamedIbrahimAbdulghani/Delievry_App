import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../../restaurant_details/domain/usecases/submit_review_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
  final SubmitReviewUseCase submitReviewUseCase;

  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
    required this.submitReviewUseCase,
  }) : super(NotificationsInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
    on<SubmitNotificationRating>(_onSubmitNotificationRating);
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
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      // Optimistic update
      final updatedNotifications = currentState.notifications.map((n) {
        return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
      }).toList();
      emit(NotificationsLoaded(updatedNotifications));
    }

    final result = await markNotificationAsReadUseCase(event.notificationId);
    result.fold(
      (failure) {
        emit(NotificationsError(failure.message));
        if (currentState is NotificationsLoaded) {
          emit(NotificationsLoaded(currentState.notifications));
        }
      },
      (_) {
        // Refresh list
        add(FetchNotifications());
      },
    );
  }

  Future<void> _onMarkAllAsRead(MarkAllAsReadEvent event, Emitter<NotificationsState> emit) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      // Optimistic update
      final updatedNotifications = currentState.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();
      emit(NotificationsLoaded(updatedNotifications));
    }

    final result = await markAllNotificationsAsReadUseCase();
    result.fold(
      (failure) {
        emit(NotificationsError(failure.message));
        if (currentState is NotificationsLoaded) {
          emit(NotificationsLoaded(currentState.notifications));
        }
      },
      (_) {
        // Refresh list
        add(FetchNotifications());
      },
    );
  }

  Future<void> _onSubmitNotificationRating(SubmitNotificationRating event, Emitter<NotificationsState> emit) async {
    emit(RatingSubmitting());
    
    final result = await submitReviewUseCase(
      orderId: event.orderId,
      rating: event.rating,
      comment: event.comment,
      notificationId: event.notificationId,
    );

    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (_) => emit(RatingSuccess()),
    );
  }
}
