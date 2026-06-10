import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/auth/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;
  final SessionManager sessionManager;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
    required this.sessionManager,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        sessionManager.setCurrentUser(user);
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerUseCase(event.name, event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        sessionManager.setCurrentUser(user);
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.forgotPassword(event.email);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(ForgotPasswordEmailSent()),
    );
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.verifyOtp(event.email, event.otp);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(OtpVerified()),
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.resetPassword(
      event.email,
      event.otp,
      event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(PasswordResetSuccess()),
    );
  }
}
