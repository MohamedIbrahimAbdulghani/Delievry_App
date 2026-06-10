import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.isAdmin,
    super.phone,
    super.imageUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isAdmin: json['is_admin'] ?? false,
      phone: json['phone'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'is_admin': isAdmin,
      'phone': phone,
      'image_url': imageUrl,
    };
  }
}
