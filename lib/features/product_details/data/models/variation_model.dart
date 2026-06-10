import '../../domain/entities/variation_entity.dart';

class VariationModel extends VariationEntity {
  const VariationModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory VariationModel.fromJson(Map<String, dynamic> json) {
    return VariationModel(
      id: json['id'].toString(),
      name: json['name'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}
