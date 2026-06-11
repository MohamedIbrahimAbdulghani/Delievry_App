import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../orders/data/models/order_model.dart';

abstract class DeliveryRemoteDataSource {
  Future<List<OrderModel>> getAssignedOrders();
  Future<OrderModel> updateDeliveryStatus(int orderId, String status);
  Future<OrderModel> updateDriverLocation(int orderId, double latitude, double longitude);
  Future<UserModel> toggleAvailability(bool isOnline);
  Future<Map<String, dynamic>> getDriverEarnings();
  Future<List<OrderModel>> getDeliveryHistory({int page = 1});
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final DioClient dioClient;

  DeliveryRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<OrderModel>> getAssignedOrders() async {
    try {
      final response = await dioClient.get('/delivery/orders');
      if (response.statusCode == 200) {
        final List data = response.data['data']['items'] ?? [];
        return data.map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw ServerException('Failed to load assigned orders');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<OrderModel> updateDeliveryStatus(int orderId, String status) async {
    try {
      final response = await dioClient.post(
        '/delivery/orders/$orderId/status',
        data: {'status': status, '_method': 'PATCH'},
      );
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      }
      throw ServerException(response.data['message'] ?? 'Failed to update delivery status');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<OrderModel> updateDriverLocation(int orderId, double latitude, double longitude) async {
    try {
      final response = await dioClient.post(
        '/delivery/orders/$orderId/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          '_method': 'PATCH',
        },
      );
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      }
      throw ServerException(response.data['message'] ?? 'Failed to update location');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> toggleAvailability(bool isOnline) async {
    try {
      final response = await dioClient.post(
        '/delivery/availability',
        data: {'is_online': isOnline},
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      }
      throw ServerException(response.data['message'] ?? 'Failed to update availability');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getDriverEarnings() async {
    try {
      final response = await dioClient.get('/delivery/earnings');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw ServerException('Failed to load earnings');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getDeliveryHistory({int page = 1}) async {
    try {
      final response = await dioClient.get('/delivery/history', queryParameters: {'page': page});
      if (response.statusCode == 200) {
        final List data = response.data['data']['items'] ?? [];
        return data.map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw ServerException('Failed to load history');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
