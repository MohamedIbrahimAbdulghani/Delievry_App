import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationsEvent {}

class MarkAsReadEvent extends NotificationsEvent {
  final int notificationId;

  const MarkAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class SubmitNotificationRating extends NotificationsEvent {
  final int restaurantId;
  final double rating;
  final String comment;
  final int notificationId;

  const SubmitNotificationRating({
    required this.restaurantId,
    required this.rating,
    required this.comment,
    required this.notificationId,
  });

  @override
  List<Object?> get props => [restaurantId, rating, comment, notificationId];
}
