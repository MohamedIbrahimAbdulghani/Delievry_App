import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../di/injection_container.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashBloc>()..add(CheckAppInitialization()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToOnboarding) {
            context.go('/onboarding');
          } else if (state is SplashNavigateToLogin) {
            context.go('/login');
          } else if (state is SplashNavigateToHome) {
            context.go('/home');
          } else if (state is SplashNavigateToAdminDashboard) {
            context.go('/admin/dashboard');
          } else if (state is SplashError) {
            context.showErrorToast(
              title: 'Initialization Error',
              message: state.message,
            );
            // Fallback to login
            context.go('/login');
          }
        },
        child: const Scaffold(
          backgroundColor: AppColors.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimalist UI with just an Icon and Text for now, or Lottie if we add asset.
                Icon(
                  Icons.delivery_dining,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Delivry',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
