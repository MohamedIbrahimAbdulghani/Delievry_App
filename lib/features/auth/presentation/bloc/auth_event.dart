import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested(this.name, this.email, this.password);

  @override
  List<Object> get props => [name, email, password];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested(this.email);

  @override
  List<Object> get props => [email];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const VerifyOtpRequested(this.email, this.otp);

  @override
  List<Object> get props => [email, otp];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String password;

  const ResetPasswordRequested(this.email, this.otp, this.password);

  @override
  List<Object> get props => [email, otp, password];
}

class LogoutRequested extends AuthEvent {}
