import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> markAsRead(int notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dioClient.get('/notifications');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => NotificationModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw ServerException('Failed to load notifications');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<NotificationModel> markAsRead(int notificationId) async {
    try {
      final response = await dioClient.post(
        '/notifications/$notificationId/read',
        data: {'_method': 'PATCH'},
      );
      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data['data']);
      }
      throw ServerException('Failed to mark notification as read');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
