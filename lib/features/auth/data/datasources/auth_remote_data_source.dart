import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> forgotPassword(String email);
  Future<void> verifyOtp(String email, String otp);
  Future<void> resetPassword(String email, String otp, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      
      if (response.statusCode == 200) {
        // Assuming response structure: { data: { user: {...}, token: "..." } }
        final data = response.data['data'];
        await dioClient.secureStorage.write(key: 'token', value: data['token']);
        return UserModel.fromJson(data['user']);
      } else {
        throw ServerException(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Laravel standard
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        await dioClient.secureStorage.write(key: 'token', value: data['token']);
        return UserModel.fromJson(data['user']);
      } else {
        throw ServerException(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await dioClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      if (response.statusCode != 200) {
        throw ServerException(response.data['message'] ?? 'Failed to send OTP');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    try {
      final response = await dioClient.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      if (response.statusCode != 200) {
        throw ServerException(response.data['message'] ?? 'Invalid OTP');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email, String otp, String password) async {
    try {
      final response = await dioClient.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': password,
        },
      );
      if (response.statusCode != 200) {
        throw ServerException(response.data['message'] ?? 'Failed to reset password');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
