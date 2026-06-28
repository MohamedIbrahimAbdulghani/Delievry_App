import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../../core/network/dio_client.dart';
import '../../../home/domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/meal_entity.dart';
import '../../../home/domain/entities/category_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../profile/domain/repositories/user_repository.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../../core/settings/presentation/bloc/settings_cubit.dart';
import '../../../../core/settings/presentation/bloc/settings_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../../core/utils/data_localization_helper.dart';
import 'package:intl/intl.dart' as intl;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late AdminBloc _adminBloc;
  int _activeTab = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<NotificationEntity> _notifications = [];
  StreamSubscription? _notificationSubscription;

  final List<IconData> _tabIcons = [
    Icons.dashboard_rounded,
    Icons.receipt_long_rounded,
    Icons.restaurant_rounded,
    Icons.fastfood_rounded,
    Icons.category_rounded,
    Icons.people_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_rounded,
  ];

  List<String> _tabTitles(BuildContext context) {
    final l = AppLocalizations.of(context);
    return [
      l?.tabDashboard ?? 'Dashboard',
      l?.tabOrders ?? 'Orders',
      l?.tabRestaurants ?? 'Restaurants',
      l?.tabMeals ?? 'Meals',
      l?.tabCategories ?? 'Categories',
      l?.tabUsers ?? 'Users',
      l?.tabAnalytics ?? 'Analytics',
      l?.tabSettings ?? 'Settings',
    ];
  }

  @override
  void initState() {
    super.initState();
    _adminBloc = sl<AdminBloc>()..add(FetchAdminData());
    _fetchNotifications();
    _listenToRealtimeNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await sl<DioClient>().get('/notifications');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        if (mounted) {
          setState(() {
            _notifications = data.map((json) => NotificationEntity(
              id: json['id'],
              userId: json['user_id'],
              title: json['title'],
              body: json['body'],
              isRead: json['is_read'] ?? false,
              restaurantId: json['restaurant_id'],
              isRated: json['is_rated'] ?? false,
              orderId: json['order_id'],
              createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
            )).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  void _listenToRealtimeNotifications() async {
    try {
      final token = await sl<SessionManager>().getToken();
      if (token == null) return;

      final client = sl<DioClient>();
      final response = await client.dio.get<ResponseBody>(
        '/notifications/stream',
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      _notificationSubscription = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.startsWith('data: ')) {
              final jsonStr = line.substring(6);
              try {
                final json = jsonDecode(jsonStr);
                if (json['connected'] == true) return;

                final notification = NotificationEntity(
                  id: json['id'],
                  userId: json['user_id'],
                  title: json['title'],
                  body: json['body'],
                  isRead: json['is_read'] ?? false,
                  restaurantId: json['restaurant_id'],
                  isRated: json['is_rated'] ?? false,
                  orderId: json['order_id'],
                  createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
                );

                if (mounted) {
                  setState(() {
                    _notifications.insert(0, notification);
                  });
                  context.showInfoToast(
                    title: notification.title,
                    message: notification.body,
                    duration: const Duration(seconds: 4),
                  );
                }
              } catch (e) {
                debugPrint('Error parsing notification JSON: $e');
              }
            }
          }, onError: (error) {
            debugPrint('Notification stream error: $error');
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) _listenToRealtimeNotifications();
            });
          }, onDone: () {
            debugPrint('Notification stream finished');
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) _listenToRealtimeNotifications();
            });
          });
    } catch (e) {
      debugPrint('Error starting notification stream: $e');
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) _listenToRealtimeNotifications();
      });
    }
  }

  Future<void> _markNotificationRead(int id) async {
    try {
      final response = await sl<DioClient>().post('/notifications/$id/read', data: {'_method': 'PATCH'});
      if (response.statusCode == 200) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(isRead: true);
          }
        });
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllNotificationsRead() async {
    try {
      final response = await sl<DioClient>().post('/notifications/read-all');
      if (response.statusCode == 200) {
        setState(() {
          _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Widget _buildNotificationPanel() {
    final l = AppLocalizations.of(context);
    final unread = _notifications.where((n) => !n.isRead).toList();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l?.notifications ?? 'Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                if (unread.isNotEmpty)
                  TextButton(
                    onPressed: _markAllNotificationsRead,
                    child: Text(l?.markAllAsRead ?? 'Mark all as read'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 48, color: Theme.of(context).colorScheme.onSurface.withAlpha(100)),
                        const SizedBox(height: 8),
                        Text(l?.noNotificationsYet ?? 'No notifications yet', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return Container(
                        color: n.isRead ? null : AppColors.primary.withAlpha(10),
                        child: ListTile(
                          title: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(n.body, style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(n.createdAt),
                                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)),
                              ),
                            ],
                          ),
                          trailing: n.isRead
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.circle, color: AppColors.primary, size: 12),
                                  onPressed: () => _markNotificationRead(n.id),
                                  tooltip: l?.markAllAsRead ?? 'Mark as read',
                                ),
                          onTap: () {
                            if (!n.isRead) {
                              _markNotificationRead(n.id);
                            }
                            if (n.orderId != null) {
                              Navigator.pop(context);
                              setState(() {
                                _activeTab = 1;
                                _orderSearchQuery = n.orderId.toString();
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _adminBloc,
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is! AdminLoaded) return const SizedBox.shrink();
            return _buildFAB(context, state) ?? const SizedBox.shrink();
          },
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 1,
          title: Text(
            '${AppLocalizations.of(context)?.adminDashboard ?? "Admin"}: ${_tabTitles(context)[_activeTab]}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          leading: MediaQuery.of(context).size.width < 800
              ? IconButton(
                  icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                )
              : const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
          actions: [
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Premium language indicator
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.read<SettingsCubit>().toggleLocale(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, color: AppColors.primary, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              settingsState.locale.languageCode == 'ar' ? 'AR' : 'EN',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Animated theme toggle
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => RotationTransition(turns: animation, child: child),
                        child: Icon(
                          settingsState.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          key: ValueKey(settingsState.themeMode),
                          color: AppColors.primary,
                        ),
                      ),
                      onPressed: () => context.read<SettingsCubit>().toggleTheme(),
                    ),
                  ],
                );
              },
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded, color: AppColors.primary),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
                if (_notifications.any((n) => !n.isRead))
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_notifications.where((n) => !n.isRead).length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
              onPressed: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
        drawer: MediaQuery.of(context).size.width < 800
            ? Drawer(
                child: _buildSidebar(context, isDrawer: true),
              )
            : null,
        endDrawer: Drawer(
          child: _buildNotificationPanel(),
        ),
        body: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 800)
              Container(
                width: 240,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: BorderDirectional(end: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
                ),
                child: _buildSidebar(context),
              ),
            Expanded(
              child: BlocListener<AdminBloc, AdminState>(
                listener: (context, state) {
                  if (state is AdminActionSuccess) {
                    context.showSuccessToast(
                      title: 'Success',
                      message: state.message,
                    );
                  } else if (state is AdminActionFailure) {
                    context.showErrorToast(
                      title: 'Error',
                      message: state.message,
                    );
                  }
                },
                child: BlocBuilder<AdminBloc, AdminState>(
                  buildWhen: (previous, current) =>
                      current is AdminLoading || current is AdminLoaded || current is AdminError,
                  builder: (context, state) {
                    if (state is AdminLoading) {
                      return const AdminDashboardSkeleton();
                    } else if (state is AdminLoaded) {
                      return _buildActiveView(state);
                    } else if (state is AdminError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _adminBloc.add(FetchAdminData()),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {bool isDrawer = false}) {
    final l = AppLocalizations.of(context);
    final titles = _tabTitles(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l?.delivryHub ?? 'Delivry Hub',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                l?.platformControl ?? 'Platform Control',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(150)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: _tabIcons.length,
            itemBuilder: (context, index) {
              final isSelected = _activeTab == index;
              return ListTile(
                leading: Icon(
                  _tabIcons[index],
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
                title: Text(
                  titles[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedTileColor: AppColors.primary.withAlpha(20),
                onTap: () {
                  setState(() {
                    _activeTab = index;
                  });
                  if (isDrawer) {
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l?.confirmLogout ?? 'Confirm Logout'),
        content: Text(l?.logoutConfirmationText ?? 'Are you sure you want to log out of the admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l?.cancel ?? 'Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await sl<UserRepository>().logout();
              } catch (_) {}
              await sl<SessionManager>().clear();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(l?.logout ?? 'Logout', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView(AdminLoaded state) {
    switch (_activeTab) {
      case 0:
        return _buildDashboardView(state);
      case 1:
        return _buildOrdersView(state);
      case 2:
        return _buildRestaurantsView(state);
      case 3:
        return _buildMealsView(state);
      case 4:
        return _buildCategoriesView(state);
      case 5:
        return _buildUsersView(state);
      case 6:
        return _buildAnalyticsView(state);
      case 7:
        return _buildSettingsView(state);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildFAB(BuildContext context, AdminLoaded state) {
    if (MediaQuery.of(context).size.width >= 800) return null;

    switch (_activeTab) {
      case 2: // Restaurants
        return FloatingActionButton(
          heroTag: 'fab_restaurants',
          onPressed: () => _showRestaurantForm(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 3: // Meals
        return FloatingActionButton(
          heroTag: 'fab_meals',
          onPressed: () => _showMealForm(context, state.restaurants, state.categories),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 4: // Categories
        return FloatingActionButton(
          heroTag: 'fab_categories',
          onPressed: () => _showCategoryForm(context, state.restaurants),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 5: // Users
        return FloatingActionButton(
          heroTag: 'fab_users',
          onPressed: () => _showUserForm(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        );
      default:
        return null;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _localizedStatus(BuildContext context, OrderStatus status) {
    final l = AppLocalizations.of(context);
    switch (status) {
      case OrderStatus.pending:
        return l?.statusPending ?? 'Pending';
      case OrderStatus.preparing:
        return l?.statusPreparing ?? 'Preparing';
      case OrderStatus.heading_to_restaurant:
        return l?.statusHeadingToRestaurant ?? 'Heading to Restaurant';
      case OrderStatus.picked_up:
        return l?.statusPickedUp ?? 'Picked Up';
      case OrderStatus.out_for_delivery:
        return l?.statusOutForDelivery ?? 'Out for Delivery';
      case OrderStatus.delivered:
        return l?.statusDelivered ?? 'Delivered';
      case OrderStatus.failed:
        return l?.statusFailed ?? 'Failed';
      case OrderStatus.cancelled:
        return l?.statusCancelled ?? 'Cancelled';
    }
  }

  // -------------------------------------------------------------
  // TAB 0: DASHBOARD VIEW
  // -------------------------------------------------------------
  Widget _buildDashboardView(AdminLoaded state) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final pendingCount = state.orders.where((o) => o.status == OrderStatus.pending).length;
    final totalDrivers = state.drivers.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Cards Grid (8 Cards)
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 600
                ? 2
                : MediaQuery.of(context).size.width < 1100
                    ? 3
                    : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                l?.statTotalRevenue ?? 'Total Revenue',
                DataLocalizationHelper.formatCurrency(context, state.totalRevenue),
                Icons.monetization_on_rounded,
                [const Color(0xFF43A047), const Color(0xFF66BB6A)],
              ),
              _buildStatCard(
                l?.statTotalOrders ?? 'Total Orders',
                DataLocalizationHelper.formatNumber(context, state.totalOrders),
                Icons.shopping_bag_rounded,
                [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
              ),
              _buildStatCard(
                l?.statPendingOrders ?? 'Pending Orders',
                DataLocalizationHelper.formatNumber(context, pendingCount),
                Icons.pending_actions_rounded,
                [const Color(0xFFFDD835), const Color(0xFFFBC02D)],
              ),
              _buildStatCard(
                l?.statRestaurants ?? 'Restaurants',
                DataLocalizationHelper.formatNumber(context, state.totalRestaurants),
                Icons.restaurant_rounded,
                [const Color(0xFFF4511E), const Color(0xFFFF7043)],
              ),
              _buildStatCard(
                l?.statMealsAvailable ?? 'Meals Available',
                DataLocalizationHelper.formatNumber(context, state.totalMeals),
                Icons.fastfood_rounded,
                [const Color(0xFFE53935), const Color(0xFFEF5350)],
              ),
              _buildStatCard(
                l?.statCategories ?? 'Categories',
                DataLocalizationHelper.formatNumber(context, state.totalCategories),
                Icons.category_rounded,
                [const Color(0xFF00ACC1), const Color(0xFF26C6DA)],
              ),
              _buildStatCard(
                l?.statActiveDrivers ?? 'Active Drivers',
                DataLocalizationHelper.formatNumber(context, totalDrivers),
                Icons.delivery_dining_rounded,
                [const Color(0xFF8E24AA), const Color(0xFFAB47BC)],
              ),
              _buildStatCard(
                l?.statUsersRegistered ?? 'Users Registered',
                DataLocalizationHelper.formatNumber(context, state.totalUsers),
                Icons.people_rounded,
                [const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Recent Orders and Top Restaurants Split
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l?.latestOrders ?? 'Latest Orders',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        state.recentOrders.isEmpty
                            ? Center(child: Text(l?.noOrdersYet ?? 'No orders yet.'))
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.recentOrders.length > 5 ? 5 : state.recentOrders.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final order = state.recentOrders[index];
                                  final restName = isAr ? (order.restaurant.nameAr ?? order.restaurant.name) : (order.restaurant.nameEn ?? order.restaurant.name);
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      '${l?.orderLabel ?? "Order"} #${DataLocalizationHelper.formatNumber(context, order.id)} - $restName',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text('${_formatDate(order.createdAt)} | ${l?.statusLabel ?? "Status"}: ${_localizedStatus(context, order.status)}'),
                                    trailing: Text(
                                      DataLocalizationHelper.formatCurrency(context, order.totalAmount),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (MediaQuery.of(context).size.width >= 1100)
                Expanded(
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l?.topRestaurants ?? 'Top Restaurants',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          state.topPerformingRestaurants.isEmpty
                              ? Center(child: Text(l?.noPerformanceData ?? 'No performance data.'))
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state.topPerformingRestaurants.length,
                                  separatorBuilder: (context, index) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final rest = state.topPerformingRestaurants[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        rest['name'],
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      trailing: Text(
                                        DataLocalizationHelper.formatCurrency(context, rest['revenue']),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(color: colors[0].withAlpha(40), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: Colors.white.withAlpha(190), size: 22),
            ],
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: ORDERS MANAGEMENT
  // -------------------------------------------------------------
  String _orderSearchQuery = '';
  OrderStatus? _orderFilterStatus;

  Widget _buildOrdersView(AdminLoaded state) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final filtered = state.orders.where((o) {
      final matchesSearch = o.id.toString().contains(_orderSearchQuery) ||
          o.restaurant.name.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
          o.deliveryAddress.toLowerCase().contains(_orderSearchQuery.toLowerCase());
      final matchesStatus = _orderFilterStatus == null || o.status == _orderFilterStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Filter Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l?.searchOrders2 ?? 'Search orders by ID, restaurant, or address...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _orderSearchQuery = v),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<OrderStatus?>(
                value: _orderFilterStatus,
                hint: Text(l?.filterStatus ?? 'Filter Status'),
                items: [
                  DropdownMenuItem(value: null, child: Text(l?.allStatuses ?? 'All Statuses')),
                  ...OrderStatus.values.map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(_localizedStatus(context, s)),
                      ))
                ],
                onChanged: (s) => setState(() => _orderFilterStatus = s),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Orders List
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(l?.noMatchingOrders ?? 'No matching orders found.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      final restName = isAr ? (order.restaurant.nameAr ?? order.restaurant.name) : (order.restaurant.nameEn ?? order.restaurant.name);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            '${l?.orderLabel ?? "Order"} #${DataLocalizationHelper.formatNumber(context, order.id)} - $restName',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${l?.total ?? "Total"}: ${DataLocalizationHelper.formatCurrency(context, order.totalAmount)} | ${_formatDate(order.createdAt)}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _localizedStatus(context, order.status),
                              style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () => _showOrderDetailsDialog(context, order, state.drivers),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.heading_to_restaurant:
        return Colors.teal;
      case OrderStatus.picked_up:
        return Colors.purple;
      case OrderStatus.out_for_delivery:
        return Colors.deepPurple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.failed:
        return Colors.redAccent;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  void _showOrderDetailsDialog(BuildContext context, OrderEntity order, List<Map<String, dynamic>> drivers) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final restName = isAr ? (order.restaurant.nameAr ?? order.restaurant.name) : (order.restaurant.nameEn ?? order.restaurant.name);
    showDialog(
      context: context,
      builder: (ctx) {
        String? selectedDriverId;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('${l?.orderLabel ?? "Order"} #${order.id}'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l?.restaurantLabel ?? "Restaurant"}: $restName', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${l?.customerAddress ?? "Customer Address"}: ${order.deliveryAddress}'),
                      if (order.notes != null) ...[
                        const SizedBox(height: 8),
                        Text('${l?.notesLabel ?? "Notes"}: ${order.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                      const Divider(height: 24),
                      Text('${l?.itemsLabel ?? "Items"}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('- ${item.productName} (x${DataLocalizationHelper.formatNumber(context, item.quantity)}) - ${DataLocalizationHelper.formatCurrency(context, item.unitPrice * item.quantity)}'),
                          )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${l?.totalAmount ?? "Total"}: ${DataLocalizationHelper.formatCurrency(context, order.totalAmount)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                        ],
                      ),
                      const Divider(height: 24),
                      Text('${l?.activeStatus ?? "Change Status"}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(_localizedStatus(context, order.status)),
                            selected: true,
                            onSelected: (_) {},
                            selectedColor: _getStatusColor(order.status).withAlpha(50),
                          ),
                          ...[
                            if (order.status == OrderStatus.pending) ...[
                              OrderStatus.preparing,
                              OrderStatus.cancelled,
                            ] else if (order.status == OrderStatus.preparing) ...[
                              OrderStatus.heading_to_restaurant,
                              OrderStatus.cancelled,
                            ] else if (order.status == OrderStatus.heading_to_restaurant) ...[
                              OrderStatus.picked_up,
                              OrderStatus.preparing,
                              OrderStatus.cancelled,
                            ] else if (order.status == OrderStatus.picked_up) ...[
                              OrderStatus.out_for_delivery,
                              OrderStatus.failed,
                              OrderStatus.cancelled,
                            ] else if (order.status == OrderStatus.out_for_delivery) ...[
                              OrderStatus.delivered,
                              OrderStatus.failed,
                              OrderStatus.cancelled,
                            ]
                          ].map((s) {
                            return ChoiceChip(
                              label: Text(_localizedStatus(context, s)),
                              selected: false,
                              onSelected: (selected) {
                                if (selected) {
                                  Navigator.pop(ctx);
                                  _adminBloc.add(UpdateOrderStatusEvent(orderId: order.id, status: s.apiValue));
                                }
                              },
                            );
                          }),
                        ],
                      ),
                      const Divider(height: 24),
                      Text('${l?.assignDriver ?? "Assign Driver"}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedDriverId,
                        hint: Text(l?.selectStatus ?? 'Select Driver'),
                        items: drivers.where((d) => !(d['is_blocked'] ?? false)).map((d) => DropdownMenuItem(
                              value: d['id'].toString(),
                              child: Text('${d['name']} (${d['status']})'),
                            )).toList(),
                        onChanged: (dId) {
                          if (dId != null) {
                            setModalState(() => selectedDriverId = dId);
                            Navigator.pop(ctx);
                            _adminBloc.add(AssignDriverEvent(
                              orderId: order.id,
                              driverId: int.parse(dId),
                            ));
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l?.close ?? 'Close')),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 2: RESTAURANTS MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildRestaurantsView(AdminLoaded state) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l?.manageRestaurants ?? 'Manage Restaurants', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (MediaQuery.of(context).size.width >= 800)
                ElevatedButton.icon(
                  onPressed: () => _showRestaurantForm(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(l?.addRestaurant ?? 'Add Restaurant', style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: state.restaurants.length,
              itemBuilder: (context, index) {
                final rest = state.restaurants[index];
                final isMobile = MediaQuery.of(context).size.width < 600;

                Widget buildCardContent() {
                  final leadingWidget = CircleAvatar(
                    backgroundImage: rest.imageUrl != null ? NetworkImage(rest.imageUrl!) : null,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: rest.imageUrl == null ? const Icon(Icons.restaurant, color: AppColors.primary) : null,
                  );
                  final displayName = isAr ? (rest.nameAr ?? rest.name) : (rest.nameEn ?? rest.name);
                  final displayCity = isAr ? (rest.cityAr ?? rest.city) : (rest.cityEn ?? rest.city);
                  final titleWidget = Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold));
                  final subtitleWidget = Text('$displayCity | ${l?.deliveryFeeLabel ?? "Delivery Fee"}: ${DataLocalizationHelper.formatCurrency(context, rest.deliveryFee)}');

                  if (isMobile) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              leadingWidget,
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    titleWidget,
                                    const SizedBox(height: 4),
                                    subtitleWidget,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(l?.active ?? 'Active', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 30,
                                    child: Switch(
                                      value: rest.isActive,
                                      onChanged: (active) {
                                        _adminBloc.add(UpdateRestaurantEvent(
                                          id: rest.id,
                                          data: {
                                            'name': rest.name,
                                            'name_en': rest.nameEn,
                                            'name_ar': rest.nameAr,
                                            'slug': rest.slug,
                                            'city': rest.city,
                                            'city_en': rest.cityEn,
                                            'city_ar': rest.cityAr,
                                            'address': rest.address,
                                            'address_en': rest.addressEn,
                                            'address_ar': rest.addressAr,
                                            'phone': rest.phone,
                                            'delivery_fee': rest.deliveryFee,
                                            'image_url': rest.imageUrl,
                                            'is_active': active,
                                          },
                                        ));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, color: Colors.teal),
                                    onPressed: () => _showRestaurantDetails(context, rest),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showRestaurantForm(context, restaurant: rest),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteConfirmation(context, () {
                                      _adminBloc.add(DeleteRestaurantEvent(rest.id));
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListTile(
                      leading: leadingWidget,
                      title: titleWidget,
                      subtitle: subtitleWidget,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: rest.isActive,
                            onChanged: (active) {
                              _adminBloc.add(UpdateRestaurantEvent(
                                id: rest.id,
                                data: {
                                  'name': rest.name,
                                  'name_en': rest.nameEn,
                                  'name_ar': rest.nameAr,
                                  'slug': rest.slug,
                                  'city': rest.city,
                                  'city_en': rest.cityEn,
                                  'city_ar': rest.cityAr,
                                  'address': rest.address,
                                  'address_en': rest.addressEn,
                                  'address_ar': rest.addressAr,
                                  'phone': rest.phone,
                                  'delivery_fee': rest.deliveryFee,
                                  'image_url': rest.imageUrl,
                                  'is_active': active,
                                },
                              ));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.teal),
                            onPressed: () => _showRestaurantDetails(context, rest),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showRestaurantForm(context, restaurant: rest),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(context, () {
                              _adminBloc.add(DeleteRestaurantEvent(rest.id));
                            }),
                          ),
                        ],
                      ),
                    );
                  }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: buildCardContent(),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showRestaurantDetails(BuildContext context, RestaurantEntity rest) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final displayName = isAr ? (rest.nameAr ?? rest.name) : (rest.nameEn ?? rest.name);
    final displayCity = isAr ? (rest.cityAr ?? rest.city) : (rest.cityEn ?? rest.city);
    final displayAddress = isAr ? (rest.addressAr ?? rest.address) : (rest.addressEn ?? rest.address);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(displayName),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rest.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(rest.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Text('${l?.city ?? "City"}: $displayCity', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${l?.address ?? "Address"}: $displayAddress'),
              const SizedBox(height: 8),
              Text('${l?.phoneLabel ?? "Phone"}: ${rest.phone}'),
              const SizedBox(height: 8),
              Text('${l?.deliveryFeeLabel ?? "Delivery Fee"}: ${DataLocalizationHelper.formatCurrency(context, rest.deliveryFee)}'),
              const SizedBox(height: 8),
              Text(
                '${l?.statusLabel ?? "Status"}: ${rest.isActive ? (l?.active ?? "Active") : (l?.inactiveStatus ?? "Inactive")}',
                style: TextStyle(color: rest.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l?.close ?? 'Close')),
        ],
      ),
    );
  }

  void _showRestaurantForm(BuildContext context, {RestaurantEntity? restaurant}) {
    final l = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final nameEnController = TextEditingController(text: restaurant?.nameEn ?? restaurant?.name ?? '');
    final nameArController = TextEditingController(text: restaurant?.nameAr ?? '');
    final cityEnController = TextEditingController(text: restaurant?.cityEn ?? restaurant?.city ?? '');
    final cityArController = TextEditingController(text: restaurant?.cityAr ?? '');
    final addressEnController = TextEditingController(text: restaurant?.addressEn ?? restaurant?.address ?? '');
    final addressArController = TextEditingController(text: restaurant?.addressAr ?? '');
    final phoneController = TextEditingController(text: restaurant?.phone ?? '');
    final feeController = TextEditingController(text: restaurant?.deliveryFee.toString() ?? '');
    String? imageUrl = restaurant?.imageUrl;
    bool isActive = restaurant?.isActive ?? true;

    final restaurantPresetImages = [
      {'name': 'Italian Bistro', 'url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600'},
      {'name': 'Burger Joint', 'url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600'},
      {'name': 'Sushi Bar', 'url': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600'},
      {'name': 'Coffee House', 'url': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600'},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              title: Text(restaurant == null ? (l?.addRestaurant ?? 'Add Restaurant') : (l?.editProfileDetails ?? 'Edit Restaurant')),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameEnController,
                        decoration: InputDecoration(labelText: '${l?.name ?? "Name"} (English)'),
                        validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                      ),
                      TextFormField(
                        controller: nameArController,
                        decoration: InputDecoration(labelText: '${l?.name ?? "Name"} (Arabic)'),
                      ),
                      TextFormField(
                        controller: cityEnController,
                        decoration: InputDecoration(labelText: '${l?.city ?? "City"} (English)'),
                        validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                      ),
                      TextFormField(
                        controller: cityArController,
                        decoration: InputDecoration(labelText: '${l?.city ?? "City"} (Arabic)'),
                      ),
                      TextFormField(
                        controller: addressEnController,
                        decoration: InputDecoration(labelText: '${l?.address ?? "Address"} (English)'),
                        validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                      ),
                      TextFormField(
                        controller: addressArController,
                        decoration: InputDecoration(labelText: '${l?.address ?? "Address"} (Arabic)'),
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: l?.phoneLabel ?? 'Phone'),
                        validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                      ),
                      TextFormField(
                        controller: feeController,
                        decoration: InputDecoration(labelText: l?.deliveryFeeLabel ?? 'Delivery Fee'),
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v ?? '') == null ? 'Must be a valid number' : null,
                      ),
                      const SizedBox(height: 16),
                      // Custom image upload dialog mockup
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(l?.restaurantImage ?? 'Restaurant Image', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      imageUrl != null
                          ? Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover),
                              ),
                            )
                          : Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.image_search, size: 40),
                            ),
                      TextButton.icon(
                        onPressed: () {
                          _showImageSelector(context, restaurantPresetImages, (url) {
                            setStateBuilder(() => imageUrl = url);
                          });
                        },
                        icon: const Icon(Icons.upload),
                        label: Text(l?.simulateImageUpload ?? 'Simulate Image Upload'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l?.accountStatusLabel ?? 'Active Status'),
                          Switch(
                            value: isActive,
                            onChanged: (val) => setStateBuilder(() => isActive = val),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l?.cancel ?? 'Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final data = {
                        'name': {'en': nameEnController.text, 'ar': nameArController.text},
                        'city': {'en': cityEnController.text, 'ar': cityArController.text},
                        'address': {'en': addressEnController.text, 'ar': addressArController.text},
                        'phone': phoneController.text,
                        'delivery_fee': double.parse(feeController.text),
                        'image_url': imageUrl,
                        'is_active': isActive,
                        'slug': nameEnController.text.toLowerCase().replaceAll(' ', '-'),
                      };
                      if (restaurant == null) {
                        _adminBloc.add(CreateRestaurantEvent(data));
                      } else {
                        _adminBloc.add(UpdateRestaurantEvent(id: restaurant.id, data: data));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(l?.save ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageSelector(BuildContext context, List<Map<String, String>> presets, Function(String) onSelect) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        bool uploading = false;
        double progress = 0.0;
        final customUrlController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(l?.selectUploadImage ?? 'Select / Upload Image'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (uploading) ...[
                        Text(l?.uploadingFile ?? 'Uploading File...'),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 16),
                      ] else ...[
                        Text(l?.chooseFromPremiumPresets ?? 'Choose from Premium Presets:'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: presets.length,
                            itemBuilder: (context, index) {
                              final p = presets[index];
                              return GestureDetector(
                                onTap: () {
                                  onSelect(p['url']!);
                                  Navigator.pop(ctx);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(p['url']!, fit: BoxFit.cover),
                                      Container(color: Colors.black26),
                                      Center(
                                        child: Text(
                                          p['name']!,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(height: 24),
                        Text(l?.orEnterCustomImageUrl ?? 'Or Enter Custom Image URL:'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: customUrlController,
                          decoration: const InputDecoration(labelText: 'URL String'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (customUrlController.text.isNotEmpty) {
                              onSelect(customUrlController.text);
                              Navigator.pop(ctx);
                            }
                          },
                          child: Text(l?.applyUrl ?? 'Apply URL'),
                        ),
                        const Divider(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            setModalState(() {
                              uploading = true;
                              progress = 0.1;
                            });
                            // Simulate upload loading
                            for (int i = 2; i <= 10; i++) {
                              await Future.delayed(const Duration(milliseconds: 150));
                              if (context.mounted) {
                                setModalState(() {
                                  progress = i / 10.0;
                                });
                              }
                            }
                            onSelect(presets[0]['url']!);
                            if (context.mounted) {
                              Navigator.pop(ctx);
                            }
                          },
                          icon: const Icon(Icons.file_upload),
                          label: Text(l?.mockLocalFileUpload ?? 'Mock Local File Upload'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l?.close ?? 'Close')),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, VoidCallback onConfirm) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l?.confirmDelete ?? 'Confirm Delete'),
        content: Text(l?.areYouSureYouWantToDeleteThisEntityThisActionIsDestructiveAndCannotBeUndone ?? 'Are you sure you want to delete this entity? This action is destructive and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l?.cancel ?? 'Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(l?.delete ?? 'Delete', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: MEALS MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildMealsView(AdminLoaded state) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l?.manageMeals ?? 'Manage Meals', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (MediaQuery.of(context).size.width >= 800)
                ElevatedButton.icon(
                  onPressed: () => _showMealForm(context, state.restaurants, state.categories),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(l?.addMeal ?? 'Add Meal', style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: state.meals.length,
              itemBuilder: (context, index) {
                final meal = state.meals[index];
                final matchedRestaurant = state.restaurants.cast<RestaurantEntity?>().firstWhere(
                  (r) => r?.id == meal.restaurantId,
                  orElse: () => null,
                );
                final isMobile = MediaQuery.of(context).size.width < 600;

                Widget buildCardContent() {
                  final leadingWidget = CircleAvatar(
                    backgroundImage: meal.imageUrl != null ? NetworkImage(meal.imageUrl!) : null,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: meal.imageUrl == null ? const Icon(Icons.fastfood, color: AppColors.primary) : null,
                  );
                  final displayName = isAr ? (meal.nameAr ?? meal.name) : (meal.nameEn ?? meal.name);
                  final displayRestName = matchedRestaurant != null
                      ? (isAr ? (matchedRestaurant.nameAr ?? matchedRestaurant.name) : (matchedRestaurant.nameEn ?? matchedRestaurant.name))
                      : 'Unknown';
                  final titleWidget = Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold));
                  final subtitleWidget = Text('${l?.priceLabel ?? "Price"}: ${DataLocalizationHelper.formatCurrency(context, meal.price)} | ${l?.categoryLabel ?? "Category"}: ${meal.category} | ${l?.restaurantLabel2 ?? "Rest"}: $displayRestName');

                  if (isMobile) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              leadingWidget,
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    titleWidget,
                                    const SizedBox(height: 4),
                                    subtitleWidget,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(l?.available ?? 'Available', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 30,
                                    child: Switch(
                                      value: meal.isAvailable,
                                      onChanged: (avail) {
                                        _adminBloc.add(UpdateMealEvent(
                                          id: meal.id,
                                          data: {
                                            'restaurant_id': meal.restaurantId,
                                            'name': meal.name,
                                            'slug': meal.slug,
                                            'description': meal.description,
                                            'price': meal.price,
                                            'category': meal.category,
                                            'image_url': meal.imageUrl,
                                            'is_available': avail,
                                          },
                                        ));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, color: Colors.teal),
                                    onPressed: () => _showMealDetails(context, meal, displayRestName),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showMealForm(context, state.restaurants, state.categories, meal: meal),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteConfirmation(context, () {
                                      _adminBloc.add(DeleteMealEvent(meal.id));
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListTile(
                      leading: leadingWidget,
                      title: titleWidget,
                      subtitle: subtitleWidget,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: meal.isAvailable,
                            onChanged: (avail) {
                              _adminBloc.add(UpdateMealEvent(
                                id: meal.id,
                                data: {
                                  'restaurant_id': meal.restaurantId,
                                  'name': meal.name,
                                  'slug': meal.slug,
                                  'description': meal.description,
                                  'price': meal.price,
                                  'category': meal.category,
                                  'image_url': meal.imageUrl,
                                  'is_available': avail,
                                },
                              ));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.teal),
                            onPressed: () => _showMealDetails(context, meal, displayRestName),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showMealForm(context, state.restaurants, state.categories, meal: meal),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(context, () {
                              _adminBloc.add(DeleteMealEvent(meal.id));
                            }),
                          ),
                        ],
                      ),
                    );
                  }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: buildCardContent(),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showMealDetails(BuildContext context, MealEntity meal, String restName) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final displayName = isAr ? (meal.nameAr ?? meal.name) : (meal.nameEn ?? meal.name);
    final displayDesc = isAr ? (meal.descriptionAr ?? meal.description) : (meal.descriptionEn ?? meal.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(displayName),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meal.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(meal.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Text('${l?.priceLabel ?? "Price"}: ${DataLocalizationHelper.formatCurrency(context, meal.price)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
              const SizedBox(height: 8),
              Text('${l?.categoryLabel ?? "Category"}: ${meal.category}'),
              const SizedBox(height: 8),
              Text('${l?.restaurantLabel2 ?? "Restaurant"}: $restName'),
              const SizedBox(height: 8),
              Text('${l?.notesLabel ?? "Description"}: $displayDesc'),
              const SizedBox(height: 8),
              Text('${l?.available ?? "Available"}: ${meal.isAvailable ? (l?.yesLabel ?? "Yes") : (l?.noLabel ?? "No")}', style: TextStyle(color: meal.isAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l?.close ?? 'Close')),
        ],
      ),
    );
  }

  void _showMealForm(BuildContext context, List<RestaurantEntity> restaurants, List<CategoryEntity> categories, {MealEntity? meal}) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final formKey = GlobalKey<FormState>();
    final nameEnController = TextEditingController(text: meal?.nameEn ?? meal?.name ?? '');
    final nameArController = TextEditingController(text: meal?.nameAr ?? '');
    final descriptionEnController = TextEditingController(text: meal?.descriptionEn ?? meal?.description ?? '');
    final descriptionArController = TextEditingController(text: meal?.descriptionAr ?? '');
    final priceController = TextEditingController(text: meal?.price.toString() ?? '');
    String? selectedCategoryName = meal?.category ?? (categories.isNotEmpty ? categories.first.name : null);
    int? selectedRestaurantId = meal?.restaurantId ?? (restaurants.isNotEmpty ? restaurants.first.id : null);
    String? imageUrl = meal?.imageUrl;
    bool isAvailable = meal?.isAvailable ?? true;

    final mealPresetImages = [
      {'name': 'Pizza slice', 'url': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600'},
      {'name': 'Beef Burger', 'url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600'},
      {'name': 'Ramen noodles', 'url': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600'},
      {'name': 'Dessert Cake', 'url': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600'},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              title: Text(meal == null ? (l?.addMeal ?? 'Add Meal') : (l?.mealDetails ?? 'Edit Meal')),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(labelText: l?.restaurantLabel ?? 'Restaurant'),
                        initialValue: selectedRestaurantId,
                        items: restaurants.map((r) {
                          final rName = isAr ? (r.nameAr ?? r.name) : (r.nameEn ?? r.name);
                          return DropdownMenuItem(
                            value: r.id,
                            child: Text(rName),
                          );
                        }).toList(),
                        onChanged: (val) => selectedRestaurantId = val,
                        validator: (v) => v == null ? (l?.requiredField ?? 'Required') : null,
                      ),
                      TextFormField(
                        controller: nameEnController,
                        decoration: InputDecoration(labelText: '${l?.name ?? "Name"} (English)'),
                        validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                      ),
                      TextFormField(
                        controller: nameArController,
                        decoration: InputDecoration(labelText: '${l?.name ?? "Name"} (Arabic)'),
                      ),
                      TextFormField(
                        controller: descriptionEnController,
                        decoration: InputDecoration(labelText: '${l?.notesLabel ?? "Description"} (English)'),
                        validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                      ),
                      TextFormField(
                        controller: descriptionArController,
                        decoration: InputDecoration(labelText: '${l?.notesLabel ?? "Description"} (Arabic)'),
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(labelText: l?.priceLabel ?? 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v ?? '') == null ? 'Must be a valid number' : null,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: l?.categoryLabel ?? 'Category'),
                        initialValue: selectedCategoryName,
                        items: categories.map((c) => DropdownMenuItem(
                              value: c.name,
                              child: Text(c.name),
                            )).toList(),
                        onChanged: (val) => selectedCategoryName = val,
                        validator: (v) => v == null ? (l?.requiredField ?? 'Required') : null,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(l?.mealImage ?? 'Meal Image', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      imageUrl != null
                          ? Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover),
                              ),
                            )
                          : Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.image, size: 40),
                            ),
                      TextButton.icon(
                        onPressed: () {
                          _showImageSelector(context, mealPresetImages, (url) {
                            setStateBuilder(() => imageUrl = url);
                          });
                        },
                        icon: const Icon(Icons.upload_file),
                        label: Text(l?.simulateImageUpload ?? 'Simulate Image Upload'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l?.availableStatus ?? 'Available Status'),
                          Switch(
                            value: isAvailable,
                            onChanged: (val) => setStateBuilder(() => isAvailable = val),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l?.cancel ?? 'Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final data = {
                        'restaurant_id': selectedRestaurantId,
                        'name': {'en': nameEnController.text, 'ar': nameArController.text},
                        'description': {'en': descriptionEnController.text, 'ar': descriptionArController.text},
                        'price': double.parse(priceController.text),
                        'category': selectedCategoryName,
                        'image_url': imageUrl,
                        'is_available': isAvailable,
                        'slug': nameEnController.text.toLowerCase().replaceAll(' ', '-'),
                      };
                      if (meal == null) {
                        _adminBloc.add(CreateMealEvent(data));
                      } else {
                        _adminBloc.add(UpdateMealEvent(id: meal.id, data: data));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(l?.save ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 4: CATEGORY MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildCategoriesView(AdminLoaded state) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l?.manageCategories ?? 'Manage Categories', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (MediaQuery.of(context).size.width >= 800)
                ElevatedButton.icon(
                  onPressed: () => _showCategoryForm(context, state.restaurants),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(l?.addCategory ?? 'Add Category', style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final cat = state.categories[index];
                final isMobile = MediaQuery.of(context).size.width < 600;

                Widget buildCardContent() {
                  final leadingWidget = CircleAvatar(
                    backgroundImage: cat.imageUrl != null ? NetworkImage(cat.imageUrl!) : null,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: cat.imageUrl == null ? const Icon(Icons.category_rounded, color: AppColors.primary) : null,
                  );
                  final displayName = isAr ? (cat.nameAr ?? cat.name) : (cat.nameEn ?? cat.name);
                  final titleWidget = Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold));
                  final subtitleWidget = Text('${l?.visibilityLabel ?? "Visibility"}: ${cat.isVisible ? (l?.visibleStatus ?? "Visible") : (l?.hiddenStatus ?? "Hidden")} | ${l?.assignedRestaurantsLabel ?? "Assigned Restaurants"}: ${cat.restaurantIds.length}');

                  if (isMobile) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              leadingWidget,
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    titleWidget,
                                    const SizedBox(height: 4),
                                    subtitleWidget,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(l?.visible ?? 'Visible', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 30,
                                    child: Switch(
                                      value: cat.isVisible,
                                      onChanged: (visible) {
                                        _adminBloc.add(UpdateCategoryEvent(
                                          id: cat.id,
                                          data: {
                                            'name': cat.name,
                                            'image_url': cat.imageUrl,
                                            'is_visible': visible,
                                            'restaurant_ids': cat.restaurantIds,
                                          },
                                        ));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showCategoryForm(context, state.restaurants, category: cat),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteConfirmation(context, () {
                                      _adminBloc.add(DeleteCategoryEvent(cat.id));
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListTile(
                      leading: leadingWidget,
                      title: titleWidget,
                      subtitle: subtitleWidget,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: cat.isVisible,
                            onChanged: (visible) {
                              _adminBloc.add(UpdateCategoryEvent(
                                id: cat.id,
                                data: {
                                  'name': cat.name,
                                  'image_url': cat.imageUrl,
                                  'is_visible': visible,
                                  'restaurant_ids': cat.restaurantIds,
                                },
                              ));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showCategoryForm(context, state.restaurants, category: cat),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(context, () {
                              _adminBloc.add(DeleteCategoryEvent(cat.id));
                            }),
                          ),
                        ],
                      ),
                    );
                  }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: buildCardContent(),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showCategoryForm(BuildContext context, List<RestaurantEntity> restaurants, {CategoryEntity? category}) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final formKey = GlobalKey<FormState>();
    final nameEnController = TextEditingController(text: category?.nameEn ?? category?.name ?? '');
    final nameArController = TextEditingController(text: category?.nameAr ?? '');
    String? imageUrl = category?.imageUrl;
    bool isVisible = category?.isVisible ?? true;
    List<int> selectedRestaurantIds = List<int>.from(category?.restaurantIds ?? []);

    final categoryPresetImages = [
      {'name': 'Fast Food', 'url': 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=600'},
      {'name': 'Bakery', 'url': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600'},
      {'name': 'Asian Dishes', 'url': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600'},
      {'name': 'Drinks', 'url': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600'},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              title: Text(category == null ? (l?.addCategory ?? 'Add Category') : (l?.category ?? 'Edit Category')),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameEnController,
                          decoration: InputDecoration(labelText: '${l?.name ?? "Name"} (English)'),
                          validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                        ),
                        TextFormField(
                          controller: nameArController,
                          decoration: InputDecoration(labelText: '${l?.name ?? "Name"} (Arabic)'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(l?.categoryImage ?? 'Category Image', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        imageUrl != null
                            ? Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover),
                                ),
                              )
                            : Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.category, size: 40),
                              ),
                        TextButton.icon(
                          onPressed: () {
                            _showImageSelector(context, categoryPresetImages, (url) {
                              setStateBuilder(() => imageUrl = url);
                            });
                          },
                          icon: const Icon(Icons.photo),
                          label: Text(l?.selectPhoto ?? 'Select Photo'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l?.visibleOnAppHome ?? 'Visible on App Home'),
                            Switch(
                              value: isVisible,
                              onChanged: (val) => setStateBuilder(() => isVisible = val),
                            )
                          ],
                        ),
                        const Divider(height: 24),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(l?.assignRestaurantsToCategory ?? 'Assign Restaurants to Category', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        restaurants.isEmpty
                            ? Text(l?.noRestaurantsRegisteredToAssign ?? 'No restaurants registered to assign.')
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: restaurants.length,
                                itemBuilder: (context, index) {
                                  final r = restaurants[index];
                                  final checked = selectedRestaurantIds.contains(r.id);
                                  final rName = isAr ? (r.nameAr ?? r.name) : (r.nameEn ?? r.name);
                                  return CheckboxListTile(
                                    title: Text(rName),
                                    value: checked,
                                    onChanged: (val) {
                                      setStateBuilder(() {
                                        if (val == true) {
                                          selectedRestaurantIds.add(r.id);
                                        } else {
                                          selectedRestaurantIds.remove(r.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l?.cancel ?? 'Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final data = {
                        'name': {'en': nameEnController.text, 'ar': nameArController.text},
                        'image_url': imageUrl,
                        'is_visible': isVisible,
                        'restaurant_ids': selectedRestaurantIds,
                      };
                      if (category == null) {
                        _adminBloc.add(CreateCategoryEvent(data));
                      } else {
                        _adminBloc.add(UpdateCategoryEvent(id: category.id, data: data));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(l?.save ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // -------------------------------------------------------------
  // TAB 5: USERS MANAGEMENT
  // -------------------------------------------------------------
  String _userSearchQuery = '';
  String _userRoleFilter = 'All';
  String _userStatusFilter = 'All';

  Widget _buildUsersView(AdminLoaded state) {
    final l = AppLocalizations.of(context);
    final filteredUsers = state.users.where((u) {
      final matchesSearch = u.name.toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
          (u.phone ?? '').toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
          u.role.toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
          (u.isAdmin ? 'admin' : '').contains(_userSearchQuery.toLowerCase());

      bool matchesRole = true;
      if (_userRoleFilter == 'Admins' || _userRoleFilter == 'المسؤولين') {
        matchesRole = u.isAdmin || u.role == 'admin';
      } else if (_userRoleFilter == 'Customers' || _userRoleFilter == 'العملاء') {
        matchesRole = !u.isAdmin && u.role == 'customer';
      } else if (_userRoleFilter == 'Drivers' || _userRoleFilter == 'السائقين') {
        matchesRole = u.role == 'delivery';
      }

      bool matchesStatus = true;
      if (_userStatusFilter == 'Active' || _userStatusFilter == 'نشط') {
        matchesStatus = !u.isBlocked;
      } else if (_userStatusFilter == 'Inactive' || _userStatusFilter == 'غير نشط') {
        matchesStatus = u.isBlocked;
      }

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l?.usersManagement ?? 'Users Management', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (MediaQuery.of(context).size.width >= 800)
                ElevatedButton.icon(
                  onPressed: () => _showUserForm(context),
                  icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                  label: Text(l?.addUser ?? 'Add User', style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l?.searchUsers2 ?? 'Search users by name, email, phone, or role...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setState(() => _userSearchQuery = v),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _userRoleFilter == 'All' ? (l?.allFilter ?? 'All') : _userRoleFilter,
                hint: Text(l?.filterRole ?? 'Filter Role'),
                items: [
                  l?.allFilter ?? 'All',
                  l?.admin ?? 'Admin',
                  l?.customer ?? 'Customer',
                  l?.driver ?? 'Driver'
                ].map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r),
                )).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      if (v == (l?.allFilter ?? 'All')) {
                        _userRoleFilter = 'All';
                      } else if (v == (l?.admin ?? 'Admin')) {
                        _userRoleFilter = 'Admins';
                      } else if (v == (l?.customer ?? 'Customer')) {
                        _userRoleFilter = 'Customers';
                      } else if (v == (l?.driver ?? 'Driver')) {
                        _userRoleFilter = 'Drivers';
                      }
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _userStatusFilter == 'All' ? (l?.allFilter ?? 'All') : _userStatusFilter,
                hint: Text(l?.statusLabel ?? 'Filter Status'),
                items: [
                  l?.allFilter ?? 'All',
                  l?.active ?? 'Active',
                  l?.inactiveStatus ?? 'Inactive'
                ].map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s),
                )).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      if (v == (l?.allFilter ?? 'All')) {
                        _userStatusFilter = 'All';
                      } else if (v == (l?.active ?? 'Active')) {
                        _userStatusFilter = 'Active';
                      } else if (v == (l?.inactiveStatus ?? 'Inactive')) {
                        _userStatusFilter = 'Inactive';
                      }
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(child: Text(l?.noUsersMatchingTheFilters ?? 'No users matching the filters.'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelf = sl<SessionManager>().currentUser?.id == user.id;
                      final isMobile = MediaQuery.of(context).size.width < 600;

                      Widget buildCardContent() {
                        final isDriver = user.role == 'delivery';
                        final leadingWidget = CircleAvatar(
                          backgroundColor: user.isAdmin
                              ? AppColors.primary
                              : (isDriver ? Colors.teal[300] : Colors.grey[300]),
                          child: Icon(
                            user.isAdmin
                                ? Icons.admin_panel_settings_rounded
                                : (isDriver ? Icons.delivery_dining_rounded : Icons.person),
                            color: user.isAdmin || isDriver ? Colors.white : Colors.black87,
                          ),
                        );
                        
                        final titleRowWidget = Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (user.isBlocked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Text(
                                  l?.deactivated ?? 'Deactivated',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        );

                        final roleDisplay = isDriver ? (l?.driver ?? 'Driver') : (user.isAdmin ? (l?.admin ?? 'Admin') : (l?.customer ?? 'Customer'));
                        final subtitleWidget = Text(
                          '${user.email} | ${l?.phoneLabel ?? "Phone"}: ${user.phone ?? l?.naLabel ?? "N/A"} | ${l?.roleLabel ?? "Role"}: $roleDisplay',
                        );

                        if (isMobile) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    leadingWidget,
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          titleRowWidget,
                                          const SizedBox(height: 4),
                                          subtitleWidget,
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (!isSelf)
                                      Row(
                                        children: [
                                          Text(user.isBlocked ? (l?.activateUser ?? 'Activate') : (l?.deactivateUser ?? 'Deactivate'), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            height: 30,
                                            child: Switch(
                                              value: !user.isBlocked,
                                              activeThumbColor: Colors.green,
                                              inactiveThumbColor: Colors.red,
                                              inactiveTrackColor: Colors.red[200],
                                              onChanged: (active) {
                                                _showBlockConfirmation(context, user.name, !active, () {
                                                  _adminBloc.add(UpdateUserEvent(
                                                    id: user.id,
                                                    data: {'is_blocked': !active},
                                                  ));
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Text(l?.you ?? '(You)', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150), fontStyle: FontStyle.italic)),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.info_outline, color: Colors.teal),
                                          onPressed: () => _showUserDetails(context, user),
                                        ),
                                        if (!isSelf) ...[
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showUserForm(context, user: user),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _showDeleteConfirmation(context, () {
                                              _adminBloc.add(DeleteUserEvent(user.id));
                                            }),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          return ListTile(
                            leading: leadingWidget,
                            title: titleRowWidget,
                            subtitle: subtitleWidget,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.teal),
                                  onPressed: () => _showUserDetails(context, user),
                                ),
                                if (!isSelf) ...[
                                  Switch(
                                    value: !user.isBlocked,
                                    activeThumbColor: Colors.green,
                                    inactiveThumbColor: Colors.red,
                                    inactiveTrackColor: Colors.red[200],
                                    onChanged: (active) {
                                      _showBlockConfirmation(context, user.name, !active, () {
                                        _adminBloc.add(UpdateUserEvent(
                                          id: user.id,
                                          data: {'is_blocked': !active},
                                        ));
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showUserForm(context, user: user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteConfirmation(context, () {
                                      _adminBloc.add(DeleteUserEvent(user.id));
                                    }),
                                  ),
                                ] else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(l?.you ?? '(You)', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150), fontStyle: FontStyle.italic)),
                                  ),
                              ],
                            ),
                          );
                        }
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: buildCardContent(),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, UserEntity user) {
    final l = AppLocalizations.of(context);
    final isDriver = user.role == 'delivery';
    final roleDisplay = isDriver ? (l?.driver ?? 'Driver') : (user.isAdmin ? (l?.admin ?? 'Admin') : (l?.customer ?? 'Customer'));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l?.userProfileDetails ?? 'User Profile Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l?.name ?? "Name"}: ${user.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${l?.email ?? "Email"}: ${user.email}'),
            const SizedBox(height: 8),
            Text('${l?.phoneLabel ?? "Phone"}: ${user.phone ?? l?.naLabel ?? "N/A"}'),
            const SizedBox(height: 8),
            Text('${l?.roleLabel ?? "Role"}: $roleDisplay'),
            const SizedBox(height: 8),
            Text(
              '${l?.accountStatusLabel ?? "Account Status"}: ${user.isBlocked ? (l?.deactivated ?? "Deactivated") : (l?.active ?? "Active")}',
              style: TextStyle(color: user.isBlocked ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l?.close ?? 'Close')),
        ],
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context, String name, bool block, VoidCallback onConfirm) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(block ? (l?.deactivateUser ?? 'Deactivate User') : (l?.activateUser ?? 'Activate User')),
        content: Text(block ? 'Are you sure you want to deactivate user "$name"?' : 'Are you sure you want to activate user "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l?.cancel ?? 'Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(block ? (l?.deactivateUser ?? 'Deactivate') : (l?.activateUser ?? 'Activate'), style: TextStyle(color: block ? Colors.red : Colors.green)),
          )
        ],
      ),
    );
  }

  void _showUserForm(BuildContext context, {UserEntity? user}) {
    final l = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final passwordController = TextEditingController();
    String selectedRole = user?.role ?? (user?.isAdmin == true ? 'admin' : 'customer');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              title: Text(user == null ? (l?.addUser ?? 'Add User') : (l?.userProfileDetails ?? 'Edit User Details')),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: l?.name ?? 'Name'),
                        validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: l?.email ?? 'Email'),
                        validator: (v) => v == null || !v.contains('@') ? 'Invalid email' : null,
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: l?.phoneLabel ?? 'Phone Number'),
                      ),
                      if (user == null)
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(labelText: l?.password ?? 'Password'),
                          obscureText: true,
                          validator: (v) => v == null || v.length < 8 ? 'Password must be at least 8 chars' : null,
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: l?.roleLabel ?? 'Role'),
                        initialValue: selectedRole,
                        items: [
                          DropdownMenuItem(value: 'customer', child: Text(l?.customer ?? 'Customer')),
                          DropdownMenuItem(value: 'delivery', child: Text(l?.driver ?? 'Driver')),
                          DropdownMenuItem(value: 'admin', child: Text(l?.admin ?? 'Admin')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setStateBuilder(() => selectedRole = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l?.cancel ?? 'Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final data = {
                        'name': nameController.text,
                        'email': emailController.text,
                        'phone': phoneController.text.isEmpty ? null : phoneController.text,
                        'role': selectedRole,
                        'is_admin': selectedRole == 'admin',
                      };
                      if (user == null) {
                        data['password'] = passwordController.text;
                        _adminBloc.add(CreateUserEvent(data));
                      } else {
                        _adminBloc.add(UpdateUserEvent(id: user.id, data: data));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(l?.save ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 7: ANALYTICS & REPORTS
  // -------------------------------------------------------------
  Widget _buildAnalyticsView(AdminLoaded state) {
    final l = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l?.analyticsPerformanceReports ?? 'Analytics & Performance Reports', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          // Revenue bar chart
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l?.revenueReportsLast7Days ?? 'Revenue Reports (Last 7 Days)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  state.revenueByDay.isEmpty
                      ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: Text(l?.noRevenueDataAvailable ?? 'No revenue data available.')))
                      : SizedBox(
                          height: 180,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: state.revenueByDay.entries.map((e) {
                              final maxRevenue = state.revenueByDay.values.fold(0.0, (max, val) => val > max ? val : max);
                              final heightPct = maxRevenue > 0 ? e.value / maxRevenue : 0.0;
                              final parsedDate = DateTime.tryParse(e.key);
                              final formattedDate = parsedDate != null
                                  ? intl.DateFormat.MMMd(Localizations.localeOf(context).languageCode).format(parsedDate)
                                  : e.key.substring(5);
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(DataLocalizationHelper.formatCurrency(context, e.value), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 40,
                                    height: (heightPct * 120).clamp(10.0, 120.0),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primary, Color(0xFFFF9E80)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(formattedDate, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Top Selling Meals Section
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l?.topSellingMeals ?? 'Top Selling Meals', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  state.topSellingMeals.isEmpty
                      ? Center(child: Text(l?.noSalesRecords ?? 'No sales records.'))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.topSellingMeals.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final meal = state.topSellingMeals[index];
                            final matchedName = isAr ? (meal['name_ar'] ?? meal['name']) : (meal['name_en'] ?? meal['name']);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Text(
                                '#${DataLocalizationHelper.formatNumber(context, index + 1)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              title: Text(matchedName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${l?.unitsSoldLabel ?? "Units Sold"}: ${DataLocalizationHelper.formatNumber(context, meal['sales'])}'),
                              trailing: Text(
                                DataLocalizationHelper.formatCurrency(context, meal['revenue']),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsView(AdminLoaded state) {
    final l = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final appController = TextEditingController(text: state.settings['app_name'] ?? 'Delivry App');
    final feeController = TextEditingController(text: state.settings['delivery_fee']?.toString() ?? '2.50');
    final taxController = TextEditingController(text: state.settings['tax_rate']?.toString() ?? '0.15');
    final currencyController = TextEditingController(text: state.settings['currency'] ?? 'USD');
    final promoController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l?.systemConfigurations ?? 'System Configurations', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: appController,
                      decoration: InputDecoration(labelText: l?.applicationName ?? 'Application Name'),
                      validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: feeController,
                      decoration: InputDecoration(labelText: '${l?.deliveryFeeLabel ?? "Default Delivery Fee"} (\$)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Must be valid' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: taxController,
                      decoration: InputDecoration(labelText: '${l?.taxRate ?? "Tax Rate"} (e.g. 0.15 for 15%)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Must be valid' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: currencyController,
                      decoration: InputDecoration(labelText: l?.currencySettings ?? 'Currency Settings'),
                      validator: (v) => v == null || v.isEmpty ? (l?.requiredField ?? 'Required') : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final updatedSettings = Map<String, dynamic>.from(state.settings)
                            ..addAll({
                              'app_name': appController.text,
                              'delivery_fee': double.parse(feeController.text),
                              'tax_rate': double.parse(taxController.text),
                              'currency': currencyController.text,
                            });
                          _adminBloc.add(SaveSettingsEvent(updatedSettings));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: Text(l?.saveSettings ?? 'Save Settings', style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l?.broadcastNotification ?? 'Broadcast Notification', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(l?.sendAnInstantBroadcastPushNotificationToAllActiveCustomerDevices ?? 'Send an instant broadcast push notification to all active customer devices.',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: promoController,
                    decoration: InputDecoration(
                      hintText: l?.enterNotificationMessageHere ?? 'Enter notification message here...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (promoController.text.isNotEmpty) {
                        context.showSuccessToast(
                          title: 'Broadcast Sent',
                          message: 'Broadcast Notification Sent: "${promoController.text}"',
                        );
                        promoController.clear();
                      }
                    },
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    label: Text(l?.sendBroadcast ?? 'Send Broadcast', style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
