import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';

abstract class CheckoutRemoteDataSource {
  Future<bool> placeOrder({
    required String address,
    required String paymentMethod,
    String? notes,
  });

  Future<String> createPaymentIntent({
    required String address,
    String? notes,
  });

  Future<void> confirmPayment(String paymentIntentId);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final DioClient dioClient;

  CheckoutRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<bool> placeOrder({
    required String address,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final response = await dioClient.post('/orders', data: {
        'delivery_address': address,
        'payment_method': paymentMethod,
        'notes': notes,
      });

      if (response.statusCode == 201) {
        return true;
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> createPaymentIntent({
    required String address,
    String? notes,
  }) async {
    try {
      final response = await dioClient.post(
        '/payments/checkout-intent',
        data: {
          'delivery_address': address,
          'notes': notes ?? '',
        },
      );
      if (response.statusCode == 200) {
        return response.data['data']['client_secret'];
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to create payment intent');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> confirmPayment(String paymentIntentId) async {
    try {
      await dioClient.post(
        '/payments/confirm',
        data: {
          'payment_intent_id': paymentIntentId,
        },
      );
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

