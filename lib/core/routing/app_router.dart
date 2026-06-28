import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/search_page.dart';
import '../../features/restaurant_details/presentation/pages/restaurant_details_page.dart';
import '../../features/product_details/presentation/pages/product_details_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/orders_history_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/order_tracking_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/address_management_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/presentation/bloc/cart_state.dart';
import '../../di/injection_container.dart';
import '../auth/session_manager.dart';
import 'dart:async';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../notifications/local_notification_manager.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/delivery/presentation/pages/delivery_dashboard_page.dart';
import '../../features/delivery/presentation/pages/delivery_tracking_page.dart';
import '../../features/restaurant_details/presentation/pages/rating_page.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../settings/presentation/bloc/settings_cubit.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(sl<SettingsCubit>().stream),
  redirect: (context, state) {
    final sessionManager = sl<SessionManager>();
    final matchedLocation = state.matchedLocation;
    
    // Check if user is trying to access admin pages
    if (matchedLocation.startsWith('/admin')) {
      if (!sessionManager.isAuthenticated) {
        return '/login';
      }
      if (!sessionManager.isAdmin) {
        return '/home'; // Non-admins are redirected back to user home
      }
    }

    // Check if user is trying to access delivery pages
    if (matchedLocation.startsWith('/delivery')) {
      if (!sessionManager.isAuthenticated) {
        return '/login';
      }
      if (!sessionManager.isDelivery) {
        return '/home'; // Non-delivery drivers are redirected back to user home
      }
    }

    // Redirect delivery drivers away from customer pages
    if (sessionManager.isAuthenticated && sessionManager.isDelivery) {
      if (!matchedLocation.startsWith('/delivery') && matchedLocation != '/splash') {
        return '/delivery/dashboard';
      }
    }
    
    // If user is already authenticated and tries to open login/register/splash/onboarding, redirect appropriately
    if (sessionManager.isAuthenticated && (matchedLocation == '/login' || matchedLocation == '/register' || matchedLocation == '/splash')) {
      if (sessionManager.isAdmin) {
        return '/admin/dashboard';
      } else if (sessionManager.isDelivery) {
        return '/delivery/dashboard';
      } else {
        return '/home';
      }
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/delivery/dashboard',
      builder: (context, state) => const DeliveryDashboardPage(),
    ),
    GoRoute(
      path: '/delivery/tracking/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DeliveryTrackingPage(orderId: int.parse(id));
      },
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final email = state.extra as String;
        return OtpVerificationPage(email: email);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ResetPasswordPage(
          email: data['email'] as String,
          otp: data['otp'] as String,
        );
      },
    ),
    
    // Stateful Shell Route for Persistent Navigation Bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellPage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersHistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),

    // Sub-pages pushed outside the persistent navigation shell
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/restaurant-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RestaurantDetailsPage(restaurantId: int.parse(id));
      },
    ),
    GoRoute(
      path: '/product-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailsPage(productId: int.parse(id));
      },
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: '/order-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OrderDetailsPage(orderId: int.parse(id));
      },
    ),
    GoRoute(
      path: '/track-order/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OrderTrackingPage(orderId: int.parse(id));
      },
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const AddressManagementPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/rate-order/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        final restaurantId = extra?['restaurantId'] as int?;
        final notificationId = extra?['notificationId'] as int?;
        return RatingPage(
          orderId: int.parse(id),
          restaurantId: restaurantId,
          notificationId: notificationId,
        );
      },
    ),
  ],
);

class MainShellPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  Timer? _notificationTimer;
  final Set<int> _notifiedIds = {};

  @override
  void initState() {
    super.initState();
    _startNotificationPolling();
    _updateDeviceToken();
  }

  Future<void> _updateDeviceToken() async {
    try {
      final sessionManager = sl<SessionManager>();
      if (sessionManager.isAuthenticated) {
        final updateDeviceTokenUseCase = sl<UpdateDeviceTokenUseCase>();
        final userId = sessionManager.currentUser?.id;
        final mockToken = 'mock_fcm_token_user_$userId';
        await updateDeviceTokenUseCase(mockToken);
        debugPrint('Successfully registered mock device token: $mockToken');
      }
    } catch (e) {
      debugPrint('Failed to update device token: $e');
    }
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _startNotificationPolling() {
    _checkNotifications();
    _notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkNotifications();
    });
  }

  Future<void> _checkNotifications() async {
    try {
      final sessionManager = sl<SessionManager>();
      if (!sessionManager.isAuthenticated) {
        return;
      }
      
      final getNotifications = sl<GetNotificationsUseCase>();
      final result = await getNotifications();
      result.fold(
        (failure) => debugPrint('Failed to poll notifications: ${failure.message}'),
        (notifications) {
          for (final notification in notifications) {
            if (!notification.isRead && !_notifiedIds.contains(notification.id)) {
              _notifiedIds.add(notification.id);
              LocalNotificationManager.showNotification(
                id: notification.id,
                title: notification.title,
                body: notification.body,
              );
            }
          }
        },
      );
    } catch (e) {
      debugPrint('Error checking notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border_rounded),
            activeIcon: const Icon(Icons.favorite_rounded),
            label: AppLocalizations.of(context)!.favorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long_rounded),
            label: AppLocalizations.of(context)!.orders,
          ),
          BottomNavigationBarItem(
            icon: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                int count = 0;
                if (state is CartLoaded) {
                  count = state.cart.items.fold(0, (sum, item) => sum + item.quantity);
                }
                return Badge(
                  label: Text('$count'),
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            activeIcon: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                int count = 0;
                if (state is CartLoaded) {
                  count = state.cart.items.fold(0, (sum, item) => sum + item.quantity);
                }
                return Badge(
                  label: Text('$count'),
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.shopping_cart_rounded),
                );
              },
            ),
            label: AppLocalizations.of(context)!.cart,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person_rounded),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}
