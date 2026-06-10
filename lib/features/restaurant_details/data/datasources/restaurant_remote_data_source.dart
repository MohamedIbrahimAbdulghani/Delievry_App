import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/restaurant_detail_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<RestaurantDetailModel> getRestaurantDetails(int id);
  Future<bool> toggleFavorite(int id);
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final DioClient dioClient;

  RestaurantRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<RestaurantDetailModel> getRestaurantDetails(int id) async {
    try {
      final response = await dioClient.get('${ApiConstants.restaurants}/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        
        // The backend might not have products loaded by default, or might not have reviews
        // We ensure a robust mapping here.
        return RestaurantDetailModel.fromJson(data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch restaurant details');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> toggleFavorite(int id) async {
    try {
      final response = await dioClient.post('/favorites/toggle/$id');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data']['is_favorite'];
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to toggle favorite');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
