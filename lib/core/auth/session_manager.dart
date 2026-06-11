import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/profile/domain/entities/user_profile_entity.dart';

class SessionManager {
  final FlutterSecureStorage secureStorage;
  UserEntity? _currentUser;

  SessionManager({required this.secureStorage});

  UserEntity? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser?.isAdmin ?? false;

  bool get isDelivery => _currentUser?.role == 'delivery';

  void setCurrentUser(UserEntity? user) {
    _currentUser = user;
  }

  void setCurrentUserProfile(UserProfileEntity? profile) {
    if (profile == null) {
      _currentUser = null;
    } else {
      _currentUser = UserEntity(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        isAdmin: profile.isAdmin,
        role: profile.role,
      );
    }
  }

  Future<void> clear() async {
    _currentUser = null;
    await secureStorage.delete(key: 'token');
  }
}
