import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/session_manager.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;
  final GetUserProfileUseCase getUserProfileUseCase;
  final SessionManager sessionManager;

  SplashBloc({
    required this.sharedPreferences,
    required this.secureStorage,
    required this.getUserProfileUseCase,
    required this.sessionManager,
  }) : super(SplashInitial()) {
    on<CheckAppInitialization>(_onCheckAppInitialization);
  }

  Future<void> _onCheckAppInitialization(CheckAppInitialization event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    try {
      // Simulate splash delay for animation
      await Future.delayed(const Duration(seconds: 2));

      final hasSeenOnboarding = sharedPreferences.getBool('has_seen_onboarding') ?? false;
      
      if (!hasSeenOnboarding) {
        emit(SplashNavigateToOnboarding());
        return;
      }

      final token = await secureStorage.read(key: 'token');
      if (token != null && token.isNotEmpty) {
        final profileResult = await getUserProfileUseCase();
        await profileResult.fold(
          (failure) async {
            await sessionManager.clear();
            emit(SplashNavigateToLogin());
          },
          (profile) async {
            sessionManager.setCurrentUserProfile(profile);
            if (profile.isAdmin) {
              emit(SplashNavigateToAdminDashboard());
            } else {
              emit(SplashNavigateToHome());
            }
          },
        );
      } else {
        emit(SplashNavigateToLogin());
      }
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}
