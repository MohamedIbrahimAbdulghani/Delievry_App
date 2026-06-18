import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/session_manager.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../../../home/presentation/bloc/home_state.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;
  final GetUserProfileUseCase getUserProfileUseCase;
  final SessionManager sessionManager;
  final HomeBloc homeBloc;

  SplashBloc({
    required this.sharedPreferences,
    required this.secureStorage,
    required this.getUserProfileUseCase,
    required this.sessionManager,
    required this.homeBloc,
  }) : super(SplashInitial()) {
    on<CheckAppInitialization>(_onCheckAppInitialization);
  }

  Future<void> _onCheckAppInitialization(CheckAppInitialization event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    final stopwatch = Stopwatch()..start();
    try {
      final hasSeenOnboarding = sharedPreferences.getBool('has_seen_onboarding') ?? false;
      
      if (!hasSeenOnboarding) {
        // بنضمن إننا نستنى ثانية واحدة على الأقل عشان الأنيميشن يظهر بشكل كامل
        await _ensureMinDuration(stopwatch);
        emit(SplashNavigateToOnboarding());
        return;
      }

      final token = await secureStorage.read(key: 'token');
      if (token != null && token.isNotEmpty) {
        final profileResult = await getUserProfileUseCase();
        await profileResult.fold(
          (failure) async {
            await sessionManager.clear();
            await _ensureMinDuration(stopwatch);
            emit(SplashNavigateToLogin());
          },
          (profile) async {
            sessionManager.setCurrentUserProfile(profile);
            
            // لو المستخدم عميل عادي، بنحمل بيانات الصفحة الرئيسية في الخلفية عشان تفتح علطول
            if (!profile.isAdmin && profile.role != 'delivery') {
              homeBloc.add(FetchHomeData());
              
              try {
                // بنستنى التحميل يخلص بحد أقصى ثانية ونص عشان منأخرش العميل
                final homeState = await homeBloc.stream.firstWhere(
                  (state) => state is HomeLoaded || state is HomeError,
                ).timeout(const Duration(milliseconds: 1500));
                
                if (homeState is HomeLoaded) {
                  // بنحمل الصور في الـ Cache عشان تظهر فوراً
                  final imageUrls = <String>[];
                  for (final banner in homeState.banners) {
                    if (banner.imageUrl.isNotEmpty) {
                      imageUrls.add(banner.imageUrl);
                    }
                  }
                  for (final restaurant in homeState.restaurants) {
                    if (restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty) {
                      imageUrls.add(_resolveImageUrl(restaurant.imageUrl));
                    }
                  }
                  
                  for (final url in imageUrls) {
                    try {
                      final imageProvider = NetworkImage(url);
                      imageProvider.resolve(const ImageConfiguration());
                    } catch (_) {}
                  }
                }
              } catch (_) {
                // في حالة انتهاء الوقت أو الخطأ، بنكمل بشكل طبيعي عشان العميل ميعلقش
              }
            }

            await _ensureMinDuration(stopwatch);

            if (profile.isAdmin) {
              emit(SplashNavigateToAdminDashboard());
            } else {
              emit(SplashNavigateToHome());
            }
          },
        );
      } else {
        await _ensureMinDuration(stopwatch);
        emit(SplashNavigateToLogin());
      }
    } catch (e) {
      await _ensureMinDuration(stopwatch);
      emit(SplashError(e.toString()));
    }
  }

  Future<void> _ensureMinDuration(Stopwatch stopwatch) async {
    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds;
    const minSplashDurationMs = 1200; // 1.2 ثانية عشان الأنيميشن يظهر بشكل ممتاز
    if (elapsedMs < minSplashDurationMs) {
      await Future.delayed(Duration(milliseconds: minSplashDurationMs - elapsedMs));
    }
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.0.2.2:8000/storage/$url';
  }
}
