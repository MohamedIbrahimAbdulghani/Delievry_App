import 'package:equatable/equatable.dart';

class VariationEntity extends Equatable {
  final String id;
  final String name;
  final double price;

  const VariationEntity({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, price];
}
