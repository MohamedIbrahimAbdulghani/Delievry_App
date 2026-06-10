import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/routing/navigation_helper.dart';
import 'di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  NavigationHelper.navigateTo = (route) => appRouter.go(route);
  runApp(const DelievryApp());
}

class DelievryApp extends StatelessWidget {
  const DelievryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Delievry App',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
