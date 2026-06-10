import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String name; // e.g. "Home", "Office"
  final String address;
  final String? city;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, name, address, city, isDefault];
}
