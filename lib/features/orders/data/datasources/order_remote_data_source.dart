import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({int page = 1});
  Future<OrderModel> getOrderDetails(int id);
  Future<bool> reorder(int id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient dioClient;

  OrderRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<OrderModel>> getOrders({int page = 1}) async {
    try {
      final response = await dioClient.get('/orders', queryParameters: {'page': page});
      if (response.statusCode == 200) {
        final List data = response.data['data']['items'];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<OrderModel> getOrderDetails(int id) async {
    try {
      final response = await dioClient.get('/orders/$id');
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch order details');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> reorder(int id) async {
    // Reorder logic could be a specific endpoint or just adding items back to cart
    // For now, let's assume there's a backend endpoint
    try {
      final response = await dioClient.post('/orders/$id/reorder');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
