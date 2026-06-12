import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../../restaurant_details/domain/usecases/submit_review_usecase.dart';
import '../../domain/entities/notification_entity.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final SubmitReviewUseCase submitReviewUseCase;

  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.submitReviewUseCase,
  }) : super(NotificationsInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
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
    final result = await markNotificationAsReadUseCase(event.notificationId);
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (_) {
        // Refresh list
        add(FetchNotifications());
      },
    );
  }

  Future<void> _onSubmitNotificationRating(SubmitNotificationRating event, Emitter<NotificationsState> emit) async {
    final currentState = state;
    List<NotificationEntity> currentNotifications = [];
    if (currentState is NotificationsLoaded) {
      currentNotifications = currentState.notifications;
    }

    emit(NotificationsLoading());
    
    final result = await submitReviewUseCase(
      restaurantId: event.restaurantId,
      rating: event.rating,
      comment: event.comment,
      notificationId: event.notificationId,
    );

    result.fold(
      (failure) {
        emit(NotificationsError(failure.message));
        if (currentNotifications.isNotEmpty) {
          emit(NotificationsLoaded(currentNotifications));
        }
      },
      (_) {
        add(FetchNotifications());
      },
    );
  }
}
