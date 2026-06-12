import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.isRead,
    super.restaurantId,
    super.isRated = false,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      isRead: json['is_read'] ?? false,
      restaurantId: json['restaurant_id'],
      isRated: json['is_rated'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
