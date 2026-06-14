import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';
import '../entities/address_entity.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository repository;
  GetUserProfileUseCase(this.repository);
  Future<Either<Failure, UserProfileEntity>> call() async => await repository.getUserProfile();
}

class UpdateProfileUseCase {
  final UserRepository repository;
  UpdateProfileUseCase(this.repository);
  Future<Either<Failure, UserProfileEntity>> call({String? name, String? phone, String? imageUrl}) async =>
      await repository.updateProfile(name: name, phone: phone, imageUrl: imageUrl);
}

class GetAddressesUseCase {
  final UserRepository repository;
  GetAddressesUseCase(this.repository);
  Future<Either<Failure, List<AddressEntity>>> call() async => await repository.getAddresses();
}

class LogoutUseCase {
  final UserRepository repository;
  LogoutUseCase(this.repository);
  Future<Either<Failure, bool>> call() async => await repository.logout();
}

class UpdateDeviceTokenUseCase {
  final UserRepository repository;
  UpdateDeviceTokenUseCase(this.repository);
  Future<Either<Failure, Unit>> call(String token) async =>
      await repository.updateDeviceToken(token);
}
