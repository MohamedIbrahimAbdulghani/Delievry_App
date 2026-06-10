import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/meal_entity.dart';

class FavoriteEntity extends Equatable {
  final String id;
  final RestaurantEntity? restaurant;
  final MealEntity? meal;

  const FavoriteEntity({
    required this.id,
    this.restaurant,
    this.meal,
  });

  @override
  List<Object?> get props => [id, restaurant, meal];
}
