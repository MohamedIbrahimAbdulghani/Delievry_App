import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_profile_model.dart';
import '../models/address_model.dart';

abstract class UserRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateProfile({String? name, String? phone, String? imageUrl});
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<bool> deleteAddress(String id);
  Future<bool> logout();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient dioClient;

  UserRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await dioClient.get('/auth/user');
      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch user');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserProfileModel> updateProfile({String? name, String? phone, String? imageUrl}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (imageUrl != null) data['image_url'] = imageUrl;

      // Assuming the endpoint for updating current user
      final response = await dioClient.put('/auth/user', data: data);
      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    // Mocking addresses for now
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const AddressModel(id: '1', name: 'Home', address: '123 Market St', city: 'San Francisco', isDefault: true),
      const AddressModel(id: '2', name: 'Office', address: '456 Business Rd', city: 'San Francisco', isDefault: false),
    ];
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    // Mocking
    return address;
  }

  @override
  Future<bool> deleteAddress(String id) async {
    // Mocking
    return true;
  }

  @override
  Future<bool> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } catch (_) {
      // Ignore API errors on logout, we still want to clear local storage
    } finally {
      await dioClient.secureStorage.delete(key: 'token');
    }
    return true;
  }
}
