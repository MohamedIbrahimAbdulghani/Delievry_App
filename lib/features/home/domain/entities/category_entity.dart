import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final bool isVisible;
  final List<int> restaurantIds;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isVisible = true,
    this.restaurantIds = const [],
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    bool? isVisible,
    List<int>? restaurantIds,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isVisible: isVisible ?? this.isVisible,
      restaurantIds: restaurantIds ?? this.restaurantIds,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, isVisible, restaurantIds];
}
