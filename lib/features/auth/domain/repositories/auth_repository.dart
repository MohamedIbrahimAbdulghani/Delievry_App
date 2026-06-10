import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(String name, String email, String password);
  Future<Either<Failure, Unit>> forgotPassword(String email);
  Future<Either<Failure, Unit>> verifyOtp(String email, String otp);
  Future<Either<Failure, Unit>> resetPassword(String email, String otp, String password);
}
