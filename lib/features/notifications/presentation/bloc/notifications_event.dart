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
