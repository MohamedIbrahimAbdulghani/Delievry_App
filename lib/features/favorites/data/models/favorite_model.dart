import '../../domain/entities/favorite_entity.dart';
import '../../../home/data/models/restaurant_model.dart';
import '../../../home/data/models/meal_model.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.id,
    super.restaurant,
    super.meal,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'].toString(),
      restaurant: json['restaurant'] != null
          ? RestaurantModel.fromJson(json['restaurant'])
          : null,
      meal: json['meal'] != null
          ? MealModel.fromJson(json['meal'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant': restaurant != null ? (restaurant as RestaurantModel).toJson() : null,
      'meal': meal != null ? (meal as MealModel).toJson() : null,
    };
  }
}
