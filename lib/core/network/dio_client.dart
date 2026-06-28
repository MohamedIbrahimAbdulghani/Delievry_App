import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../routing/navigation_helper.dart';

class DioClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  DioClient({required this.dio, required this.secureStorage, required this.sharedPreferences}) {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final localeCode = sharedPreferences.getString('locale') ?? 'en';
          options.headers['Accept-Language'] = localeCode;
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final token = await secureStorage.read(key: 'token');
            if (token != null) {
              await secureStorage.delete(key: 'token');
              NavigationHelper.navigateTo?.call('/login');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(url, queryParameters: queryParameters);
  }

  Future<Response> post(String url, {dynamic data}) async {
    return await dio.post(url, data: data);
  }

  Future<Response> put(String url, {dynamic data}) async {
    return await dio.put(url, data: data);
  }

  Future<Response> delete(String url) async {
    return await dio.delete(url);
  }
}
