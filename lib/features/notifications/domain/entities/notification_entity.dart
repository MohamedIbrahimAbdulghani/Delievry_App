import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String body;
  final bool isRead;
  final int? restaurantId;
  final bool isRated;
  final int? orderId;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    this.restaurantId,
    this.isRated = false,
    this.orderId,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    bool? isRead,
    int? restaurantId,
    bool? isRated,
    int? orderId,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      restaurantId: restaurantId ?? this.restaurantId,
      isRated: isRated ?? this.isRated,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, body, isRead, restaurantId, isRated, orderId, createdAt];
}
