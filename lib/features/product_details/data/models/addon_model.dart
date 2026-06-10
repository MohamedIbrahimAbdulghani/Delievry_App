import '../../domain/entities/addon_entity.dart';

class AddonModel extends AddonEntity {
  const AddonModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
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
