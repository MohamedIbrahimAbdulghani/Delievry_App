import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String city;
  final String address;
  final String phone;
  final double deliveryFee;
  final bool isActive;
  final String? imageUrl;
  final bool isFavorite;

  const RestaurantEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.city,
    required this.address,
    required this.phone,
    required this.deliveryFee,
    required this.isActive,
    this.imageUrl,
    this.isFavorite = false,
  });

  RestaurantEntity copyWith({
    int? id,
    String? name,
    String? slug,
    String? city,
    String? address,
    String? phone,
    double? deliveryFee,
    bool? isActive,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return RestaurantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        city,
        address,
        phone,
        deliveryFee,
        isActive,
        imageUrl,
        isFavorite,
      ];
}
