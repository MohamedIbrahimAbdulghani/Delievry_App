import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../../di/injection_container.dart';
import '../bloc/delivery_bloc.dart';
import '../bloc/delivery_event.dart';
import '../bloc/delivery_state.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/assigned_orders_view.dart';
import '../widgets/delivery_history_view.dart';
import '../widgets/driver_profile_view.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../../core/settings/presentation/bloc/settings_cubit.dart';
import '../../../../core/settings/presentation/bloc/settings_state.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

class DeliveryDashboardPage extends StatefulWidget {
  const DeliveryDashboardPage({super.key});

  @override
  State<DeliveryDashboardPage> createState() => _DeliveryDashboardPageState();
}

class _DeliveryDashboardPageState extends State<DeliveryDashboardPage> {
  late DeliveryBloc _bloc;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _bloc = sl<DeliveryBloc>()..add(FetchAssignedOrders());
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
        debugPrint('Successfully registered driver device token: $mockToken');
      }
    } catch (e) {
      debugPrint('Failed to update device token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsCubit>();
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocListener<DeliveryBloc, DeliveryState>(
        listener: (context, state) {
          if (state is DeliveryActionSuccess) {
            context.showSuccessToast(
              title: 'Success',
              message: state.message,
            );
          } else if (state is DeliveryError) {
            context.showErrorToast(
              title: 'Error',
              message: state.message,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: Text(
              _currentIndex == 0
                  ? (AppLocalizations.of(context)?.driverDashboard ?? 'Dashboard')
                  : _currentIndex == 1
                      ? (AppLocalizations.of(context)?.driverOrders ?? 'Orders')
                      : _currentIndex == 2
                          ? (AppLocalizations.of(context)?.driverHistory ?? 'History')
                          : (AppLocalizations.of(context)?.driverProfile ?? 'Profile'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            actions: [
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  final isDark = settingsState.themeMode == ThemeMode.dark;
                  return IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        key: ValueKey(isDark),
                        color: isDark ? Colors.amber : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onPressed: () {
                      context.read<SettingsCubit>().toggleTheme();
                    },
                  );
                },
              ),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  final isAr = settingsState.locale.languageCode == 'ar';
                  return TextButton(
                    onPressed: () {
                      context.read<SettingsCubit>().toggleLocale();
                      _bloc.add(FetchAssignedOrders());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAr ? 'EN' : 'AR',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: BlocBuilder<DeliveryBloc, DeliveryState>(
            buildWhen: (previous, current) =>
                current is DeliveryLoading || current is DeliveryLoaded || current is DeliveryError,
            builder: (context, state) {
              if (state is DeliveryLoading) {
                return const ListSkeleton(itemCount: 4, height: 100);
              } else if (state is DeliveryLoaded) {
                return SafeArea(child: _buildBody(state));
              } else if (state is DeliveryError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _bloc.add(FetchAssignedOrders()),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text(AppLocalizations.of(context)?.retry ?? 'Retry', style: const TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                );
              }
              return const ListSkeleton(itemCount: 4, height: 100);
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard_rounded),
                label: AppLocalizations.of(context)?.driverDashboard ?? 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long_outlined),
                activeIcon: const Icon(Icons.receipt_long_rounded),
                label: AppLocalizations.of(context)?.driverOrders ?? 'Orders',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_rounded),
                label: AppLocalizations.of(context)?.driverHistory ?? 'History',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person_rounded),
                label: AppLocalizations.of(context)?.driverProfile ?? 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(DeliveryLoaded state) {
    switch (_currentIndex) {
      case 0:
        return DashboardView(state: state);
      case 1:
        return AssignedOrdersView(state: state);
      case 2:
        return DeliveryHistoryView(state: state);
      case 3:
        return DriverProfileView(state: state);
      default:
        return const SizedBox.shrink();
    }
  }
}
