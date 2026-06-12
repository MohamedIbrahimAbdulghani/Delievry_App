import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String body;
  final bool isRead;
  final int? restaurantId;
  final bool isRated;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    this.restaurantId,
    this.isRated = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, title, body, isRead, restaurantId, isRated, createdAt];
}
