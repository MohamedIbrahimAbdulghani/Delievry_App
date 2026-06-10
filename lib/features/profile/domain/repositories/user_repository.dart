import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';
import '../entities/address_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfileEntity>> getUserProfile();
  Future<Either<Failure, UserProfileEntity>> updateProfile({String? name, String? phone, String? imageUrl});
  Future<Either<Failure, List<AddressEntity>>> getAddresses();
  Future<Either<Failure, AddressEntity>> addAddress(AddressEntity address);
  Future<Either<Failure, bool>> deleteAddress(String id);
  Future<Either<Failure, bool>> logout();
}
