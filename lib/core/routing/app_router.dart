import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/delivery/presentation/pages/delivery_dashboard_page.dart';
import '../../features/delivery/presentation/pages/delivery_tracking_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
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
  ],
);

class MainShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
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
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
