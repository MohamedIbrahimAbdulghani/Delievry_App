import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? imageUrl;
  final bool isAdmin;
  final String role;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    this.phone,
    this.imageUrl,
    this.role = 'customer',
  });

  @override
  List<Object?> get props => [id, name, email, phone, imageUrl, isAdmin, role];
}
