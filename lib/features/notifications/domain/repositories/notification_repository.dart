import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Future<Either<Failure, NotificationEntity>> markAsRead(int notificationId);
  Future<Either<Failure, void>> markAllAsRead();
}
