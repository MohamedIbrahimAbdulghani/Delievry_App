import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isAdmin;
  final bool isBlocked;
  final String role;
  final bool isOnline;
  final double? latitude;
  final double? longitude;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isAdmin,
    this.isBlocked = false,
    this.role = 'customer',
    this.isOnline = false,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        isAdmin,
        isBlocked,
        role,
        isOnline,
        latitude,
        longitude,
      ];
}
