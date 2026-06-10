import 'package:equatable/equatable.dart';

class MealEntity extends Equatable {
  final int id;
  final int restaurantId;
  final String name;
  final String slug;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final String? imageUrl;

  const MealEntity({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        name,
        slug,
        description,
        price,
        category,
        isAvailable,
        imageUrl,
      ];
}
