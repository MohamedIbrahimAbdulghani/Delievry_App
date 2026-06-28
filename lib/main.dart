import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/routing/navigation_helper.dart';
import 'core/notifications/local_notification_manager.dart';
import 'di/injection_container.dart' as di;
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/settings/presentation/bloc/settings_cubit.dart';
import 'core/settings/presentation/bloc/settings_state.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51Tm6aCCyHXVRXpaFJUeQNCF8qkUEpJUPwYjLy4EPE7FnXMomxR4uQbRnM4mBgqowXGfm2DA3EN5Esq0McyWQA8AX00Ud0EYvVw';
  await Stripe.instance.applySettings();
  await di.init();
  await LocalNotificationManager.init();
  NavigationHelper.navigateTo = (route) => appRouter.go(route);
  runApp(const DelievryApp());
}

class DelievryApp extends StatelessWidget {
  const DelievryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartBloc>(
          create: (context) => di.sl<CartBloc>(),
        ),
        BlocProvider<FavoritesBloc>(
          create: (context) => di.sl<FavoritesBloc>(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => di.sl<SettingsCubit>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          debugPrint('MaterialApp.router building with locale: ${state.locale}');
          return MaterialApp.router(
            title: 'Delievry App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
