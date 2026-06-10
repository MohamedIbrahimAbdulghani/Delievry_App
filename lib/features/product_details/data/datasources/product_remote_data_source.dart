import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_detail_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductDetailModel> getProductDetails(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;

  ProductRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ProductDetailModel> getProductDetails(int id) async {
    try {
      final response = await dioClient.get('${ApiConstants.products}/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        
        // Injecting mock variations and addons since they are not in backend
        final Map<String, dynamic> enrichedData = Map.from(data);
        enrichedData['variations'] = [
          {'id': 1, 'name': 'Small', 'price': 0.0},
          {'id': 2, 'name': 'Medium', 'price': 2.0},
          {'id': 3, 'name': 'Large', 'price': 4.0},
        ];
        enrichedData['addons'] = [
          {'id': 1, 'name': 'Extra Cheese', 'price': 1.5},
          {'id': 2, 'name': 'Bacon', 'price': 2.5},
          {'id': 3, 'name': 'Avocado', 'price': 2.0},
        ];
        enrichedData['image_urls'] = [
          data['image_url'] ?? '',
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=1000',
        ];

        return ProductDetailModel.fromJson(enrichedData);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch product details');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
