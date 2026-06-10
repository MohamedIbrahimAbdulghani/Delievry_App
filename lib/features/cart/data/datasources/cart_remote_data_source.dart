import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addItem(int productId, int quantity, Map<String, dynamic>? options);
  Future<CartModel> updateItem(int lineId, int quantity, Map<String, dynamic>? options);
  Future<CartModel> removeItem(int lineId);
  Future<CartModel> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient dioClient;

  CartRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await dioClient.get('/cart');
      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch cart');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CartModel> addItem(int productId, int quantity, Map<String, dynamic>? options) async {
    try {
      final response = await dioClient.post('/cart/items', data: {
        'product_id': productId,
        'quantity': quantity,
        'options': options,
      });
      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to add item');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CartModel> updateItem(int lineId, int quantity, Map<String, dynamic>? options) async {
    try {
      final response = await dioClient.put('/cart/items/$lineId', data: {
        'quantity': quantity,
        'options': options,
      });
      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to update item');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CartModel> removeItem(int lineId) async {
    try {
      final response = await dioClient.delete('/cart/items/$lineId');
      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to remove item');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CartModel> clearCart() async {
    try {
      final response = await dioClient.delete('/cart');
      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to clear cart');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
