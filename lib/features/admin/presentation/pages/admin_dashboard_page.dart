import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../home/domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/meal_entity.dart';
import '../../../home/domain/entities/category_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../profile/domain/repositories/user_repository.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late AdminBloc _adminBloc;
  int _activeTab = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Dashboard', 'icon': Icons.dashboard_rounded},
    {'title': 'Orders', 'icon': Icons.receipt_long_rounded},
    {'title': 'Restaurants', 'icon': Icons.restaurant_rounded},
    {'title': 'Meals', 'icon': Icons.fastfood_rounded},
    {'title': 'Categories', 'icon': Icons.category_rounded},
    {'title': 'Users', 'icon': Icons.people_rounded},
    {'title': 'Drivers', 'icon': Icons.delivery_dining_rounded},
    {'title': 'Analytics', 'icon': Icons.bar_chart_rounded},
    {'title': 'Settings', 'icon': Icons.settings_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _adminBloc = sl<AdminBloc>()..add(FetchAdminData());
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
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            'Admin: ${_tabs[_activeTab]['title']}',
            style: const TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold),
          ),
          leading: MediaQuery.of(context).size.width < 800
              ? IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.onBackground),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                )
              : const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
          actions: [
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
        body: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 800)
              Container(
                width: 240,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(right: BorderSide(color: AppColors.outline, width: 1)),
                ),
                child: _buildSidebar(context),
              ),
            Expanded(
              child: BlocListener<AdminBloc, AdminState>(
                listener: (context, state) {
                  if (state is AdminActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                    );
                  } else if (state is AdminActionFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                },
                child: BlocBuilder<AdminBloc, AdminState>(
                  buildWhen: (previous, current) =>
                      current is AdminLoading || current is AdminLoaded || current is AdminError,
                  builder: (context, state) {
                    if (state is AdminLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.centerLeft,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivry Hub',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                'Platform Control',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: _tabs.length,
            itemBuilder: (context, index) {
              final tab = _tabs[index];
              final isSelected = _activeTab == index;
              return ListTile(
                leading: Icon(
                  tab['icon'],
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  tab['title'],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.onBackground,
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of the admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
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
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
        return _buildDriversView(state);
      case 7:
        return _buildAnalyticsView(state);
      case 8:
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
      case 6: // Drivers
        return FloatingActionButton(
          heroTag: 'fab_drivers',
          onPressed: () => _showDriverForm(context, state.drivers),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.delivery_dining_rounded, color: Colors.white),
        );
      default:
        return null;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // -------------------------------------------------------------
  // TAB 0: DASHBOARD VIEW
  // -------------------------------------------------------------
  Widget _buildDashboardView(AdminLoaded state) {
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
                'Total Revenue',
                '\$${state.totalRevenue.toStringAsFixed(2)}',
                Icons.monetization_on_rounded,
                [const Color(0xFF43A047), const Color(0xFF66BB6A)],
              ),
              _buildStatCard(
                'Total Orders',
                '${state.totalOrders}',
                Icons.shopping_bag_rounded,
                [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
              ),
              _buildStatCard(
                'Pending Orders',
                '$pendingCount',
                Icons.pending_actions_rounded,
                [const Color(0xFFFDD835), const Color(0xFFFBC02D)],
              ),
              _buildStatCard(
                'Restaurants',
                '${state.totalRestaurants}',
                Icons.restaurant_rounded,
                [const Color(0xFFF4511E), const Color(0xFFFF7043)],
              ),
              _buildStatCard(
                'Meals Available',
                '${state.totalMeals}',
                Icons.fastfood_rounded,
                [const Color(0xFFE53935), const Color(0xFFEF5350)],
              ),
              _buildStatCard(
                'Categories',
                '${state.totalCategories}',
                Icons.category_rounded,
                [const Color(0xFF00ACC1), const Color(0xFF26C6DA)],
              ),
              _buildStatCard(
                'Active Drivers',
                '$totalDrivers',
                Icons.delivery_dining_rounded,
                [const Color(0xFF8E24AA), const Color(0xFFAB47BC)],
              ),
              _buildStatCard(
                'Users Registered',
                '${state.totalUsers}',
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
                        const Text(
                          'Latest Orders',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        state.recentOrders.isEmpty
                            ? const Center(child: Text('No orders yet.'))
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.recentOrders.length > 5 ? 5 : state.recentOrders.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final order = state.recentOrders[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      'Order #${order.id} - ${order.restaurant.name}',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text('${_formatDate(order.createdAt)} | Status: ${order.status.displayName}'),
                                    trailing: Text(
                                      '\$${order.totalAmount.toStringAsFixed(2)}',
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
                          const Text(
                            'Top Restaurants',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          state.topPerformingRestaurants.isEmpty
                              ? const Center(child: Text('No performance data.'))
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
                                        '\$${rest['revenue'].toStringAsFixed(2)}',
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
                    hintText: 'Search orders by ID, restaurant, or address...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _orderSearchQuery = v),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<OrderStatus?>(
                value: _orderFilterStatus,
                hint: const Text('Filter Status'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Statuses')),
                  ...OrderStatus.values.map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.displayName),
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
                ? const Center(child: Text('No matching orders found.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            'Order #${order.id} - ${order.restaurant.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Total: \$${order.totalAmount.toStringAsFixed(2)} | ${_formatDate(order.createdAt)}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.displayName,
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
      case OrderStatus.confirmed:
        return Colors.blueAccent;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.accepted:
        return Colors.cyan;
      case OrderStatus.heading_to_restaurant:
        return Colors.teal;
      case OrderStatus.picked_up:
        return Colors.purple;
      case OrderStatus.on_the_way:
        return Colors.indigo;
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
    showDialog(
      context: context,
      builder: (ctx) {
        String? selectedDriverId;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Order #${order.id} Details'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Restaurant: ${order.restaurant.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Customer Address: ${order.deliveryAddress}'),
                      if (order.notes != null) ...[
                        const SizedBox(height: 8),
                        Text('Notes: ${order.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                      const Divider(height: 24),
                      const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('- ${item.productName} (x${item.quantity}) - \$${(item.unitPrice * item.quantity).toStringAsFixed(2)}'),
                          )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text('Change Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: OrderStatus.values.map((s) {
                           final isCurrent = order.status == s;
                           return ChoiceChip(
                             label: Text(s.displayName),
                             selected: isCurrent,
                             onSelected: (selected) {
                               if (selected) {
                                 Navigator.pop(ctx);
                                 _adminBloc.add(UpdateOrderStatusEvent(orderId: order.id, status: s.apiValue));
                               }
                             },
                           );
                        }).toList(),
                      ),
                      const Divider(height: 24),
                      const Text('Assign Driver:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedDriverId,
                        hint: const Text('Select Driver'),
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
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Manage Restaurants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (MediaQuery.of(context).size.width >= 800)
                ElevatedButton.icon(
                  onPressed: () => _showRestaurantForm(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Restaurant', style: TextStyle(color: Colors.white)),
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
                  final titleWidget = Text(rest.name, style: const TextStyle(fontWeight: FontWeight.bold));
                  final subtitleWidget = Text('${rest.city} | Delivery Fee: \$${rest.deliveryFee.toStringAsFixed(2)}');

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
                                  const Text('Active', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
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
                                            'slug': rest.slug,
                                            'city': rest.city,
                                            'address': rest.address,
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
                                  'slug': rest.slug,
                                  'city': rest.city,
                                  'address': rest.address,
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(rest.name),
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
              Text('City: ${rest.city}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Address: ${rest.address}'),
              const SizedBox(height: 8),
              Text('Phone: ${rest.phone}'),
              const SizedBox(height: 8),
              Text('Delivery Fee: \$${rest.deliveryFee.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Status: ${rest.isActive ? "Active" : "Inactive"}', style: TextStyle(color: rest.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showRestaurantForm(BuildContext context, {RestaurantEntity? restaurant}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: restaurant?.name ?? '');
    final cityController = TextEditingController(text: restaurant?.city ?? '');
    final addressController = TextEditingController(text: restaurant?.address ?? '');
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
              title: Text(restaurant == null ? 'Add Restaurant' : 'Edit Restaurant'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: cityController,
                        decoration: const InputDecoration(labelText: 'City'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: feeController,
                        decoration: const InputDecoration(labelText: 'Delivery Fee'),
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v ?? '') == null ? 'Must be a valid number' : null,
                      ),
                      const SizedBox(height: 16),
                      // Custom image upload dialog mockup
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Restaurant Image', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                color: Colors.grey[200],
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
                        label: const Text('Simulate Image Upload'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Active Status'),
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
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final data = {
                        'name': nameController.text,
                        'city': cityController.text,
                        'address': addressController.text,
                        'phone': phoneController.text,
                        'delivery_fee': double.parse(feeController.text),
                        'image_url': imageUrl,
                        'is_active': isActive,
                        'slug': nameController.text.toLowerCase().replaceAll(' ', '-'),
                      };
                      if (restaurant == null) {
                        _adminBloc.add(CreateRestaurantEvent(data));
                      } else {
                        _adminBloc.add(UpdateRestaurantEvent(id: restaurant.id, data: data));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageSelector(BuildContext context, List<Map<String, String>> presets, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool uploading = false;
        double progress = 0.0;
        final customUrlController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Select / Upload Image'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (uploading) ...[
                        const Text('Uploading File...'),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 16),
                      ] else ...[
                        const Text('Choose from Premium Presets:'),
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
                        const Text('Or Enter Custom Image URL:'),
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
                          child: const Text('Apply URL'),
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
                          label: const Text('Mock Local File Upload'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this entity? This action is destructive and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: MEALS MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildMealsView(AdminLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Manage Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (MediaQuery.of(context).size.width >= 800)
                ElevatedButton.icon(
                  onPressed: () => _showMealForm(context, state.restaurants, state.categories),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Meal', style: TextStyle(color: Colors.white)),
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
                final restName = matchedRestaurant?.name ?? 'Unknown';
                final isMobile = MediaQuery.of(context).size.width < 600;

                Widget buildCardContent() {
                  final leadingWidget = CircleAvatar(
                    backgroundImage: meal.imageUrl != null ? NetworkImage(meal.imageUrl!) : null,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: meal.imageUrl == null ? const Icon(Icons.fastfood, color: AppColors.primary) : null,
                  );
                  final titleWidget = Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold));
                  final subtitleWidget = Text('Price: \$${meal.price.toStringAsFixed(2)} | Category: ${meal.category} | Rest: $restName');

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
                                  const Text('Available', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
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
                                    onPressed: () => _showMealDetails(context, meal, restName),
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
                            onPressed: () => _showMealDetails(context, meal, restName),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(meal.name),
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
              Text('Price: \$${meal.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
              const SizedBox(height: 8),
              Text('Category: ${meal.category}'),
              const SizedBox(height: 8),
              Text('Restaurant: $restName'),
              const SizedBox(height: 8),
              Text('Description: ${meal.description}'),
              const SizedBox(height: 8),
              Text('Available: ${meal.isAvailable ? "Yes" : "No"}', style: TextStyle(color: meal.isAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showMealForm(BuildContext context, List<RestaurantEntity> restaurants, List<CategoryEntity> categories, {MealEntity? meal}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: meal?.name ?? '');
    final descriptionController = TextEditingController(text: meal?.description ?? '');
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
              title: Text(meal == null ? 'Add Meal' : 'Edit Meal'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Restaurant'),
                        initialValue: selectedRestaurantId,
                        items: restaurants.map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(r.name),
                            )).toList(),
                        onChanged: (val) => selectedRestaurantId = val,
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v ?? '') == null ? 'Must be a valid number' : null,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Category'),
                        initialValue: selectedCategoryName,
                        items: categories.map((c) => DropdownMenuItem(
                              value: c.name,
                              child: Text(c.name),
                            )).toList(),
                        onChanged: (val) => selectedCategoryName = val,
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Meal Image', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                color: Colors.grey[200],
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
                        label: const Text('Simulate Image Upload'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available Status'),
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
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final data = {
                        'restaurant_id': selectedRestaurantId,
                        'name': nameController.text,
                        'description': descriptionController.text,
                        'price': double.parse(priceController.text),
                        'category': selectedCategoryName,
                        'image_url': imageUrl,
                        'is_available': isAvailable,
                        'slug': nameController.text.toLowerCase().replaceAll(' ', '-'),
                      };
                      if (meal == null) {
                        _adminBloc.add(CreateMealEvent(data));
                      } else {
                        _adminBloc.add(UpdateMealEvent(id: meal.id, data: data));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Manage Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (MediaQuery.of(context).size.width >= 800)
                ElevatedButton.icon(
                  onPressed: () => _showCategoryForm(context, state.restaurants),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Category', style: TextStyle(color: Colors.white)),
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
                  final titleWidget = Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold));
                  final subtitleWidget = Text('Visibility: ${cat.isVisible ? "Visible" : "Hidden"} | Assigned Restaurants: ${cat.restaurantIds.length}');

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
                                  const Text('Visible', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
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
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.name ?? '');
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
              title: Text(category == null ? 'Add Category' : 'Edit Category'),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Category Image', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                  color: Colors.grey[200],
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
                          label: const Text('Select Photo'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Visible on App Home'),
                            Switch(
                              value: isVisible,
                              onChanged: (val) => setStateBuilder(() => isVisible = val),
                            )
                          ],
                        ),
                        const Divider(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Assign Restaurants to Category', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        restaurants.isEmpty
                            ? const Text('No restaurants registered to assign.')
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: restaurants.length,
                                itemBuilder: (context, index) {
                                  final r = restaurants[index];
                                  final checked = selectedRestaurantIds.contains(r.id);
                                  return CheckboxListTile(
                                    title: Text(r.name),
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
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final data = {
                        'name': nameController.text,
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
                  child: const Text('Save'),
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

  Widget _buildUsersView(AdminLoaded state) {
    final filteredUsers = state.users.where((u) {
      return u.name.toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_userSearchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Platform Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (MediaQuery.of(context).size.width >= 800)
                ElevatedButton.icon(
                  onPressed: () => _showUserForm(context),
                  icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                  label: const Text('Add User', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _userSearchQuery = v),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users matching the query.'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelf = sl<SessionManager>().currentUser?.id == user.id;
                      final isMobile = MediaQuery.of(context).size.width < 600;

                      Widget buildCardContent() {
                        final leadingWidget = CircleAvatar(
                          backgroundColor: user.isAdmin ? AppColors.primary : Colors.grey[300],
                          child: Icon(Icons.person, color: user.isAdmin ? Colors.white : Colors.black87),
                        );
                        final titleRowWidget = Row(
                          children: [
                            Expanded(child: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                            if (user.isBlocked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: const BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.all(Radius.circular(8))),
                                child: const Text('Blocked', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        );
                        final subtitleWidget = Text('${user.email} | Role: ${user.isAdmin ? 'Admin' : 'Customer'}');

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
                                          const Text('Active', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
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
                                      const Text('(You)', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
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
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('(You)', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('User Profile Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: ${user.email}'),
            const SizedBox(height: 8),
            Text('Admin Privileges: ${user.isAdmin ? "Yes" : "No"}'),
            const SizedBox(height: 8),
            Text('Account Status: ${user.isBlocked ? "Blocked" : "Active"}', style: TextStyle(color: user.isBlocked ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context, String name, bool block, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(block ? 'Block User' : 'Unblock User'),
        content: Text('Are you sure you want to ${block ? "block" : "unblock"} user "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(block ? 'Block' : 'Unblock', style: TextStyle(color: block ? Colors.red : Colors.green)),
          )
        ],
      ),
    );
  }

  void _showUserForm(BuildContext context, {UserEntity? user}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    bool isAdmin = user?.isAdmin ?? false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              title: Text(user == null ? 'Add User' : 'Edit User Details'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => v == null || !v.contains('@') ? 'Invalid email' : null,
                      ),
                      if (user == null)
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (v) => v == null || v.length < 8 ? 'Password must be at least 8 chars' : null,
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Make Admin Privilege'),
                          Switch(
                            value: isAdmin,
                            onChanged: (val) => setStateBuilder(() => isAdmin = val),
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
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (user == null) {
                        final data = {
                          'name': nameController.text,
                          'email': emailController.text,
                          'password': passwordController.text,
                          'is_admin': isAdmin,
                        };
                        _adminBloc.add(CreateUserEvent(data));
                      } else {
                        final data = {
                          'name': nameController.text,
                          'email': emailController.text,
                          'is_admin': isAdmin,
                        };
                        _adminBloc.add(UpdateUserEvent(id: user.id, data: data));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 6: DELIVERY DRIVERS
  // -------------------------------------------------------------
  Widget _buildDriversView(AdminLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Drivers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (MediaQuery.of(context).size.width >= 800)
                ElevatedButton.icon(
                  onPressed: () => _showDriverForm(context, state.drivers),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Driver', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: state.drivers.length,
              itemBuilder: (context, index) {
                final d = state.drivers[index];
                final isBlocked = d['is_blocked'] ?? false;
                final isMobile = MediaQuery.of(context).size.width < 600;

                Widget buildCardContent() {
                  const leadingWidget = Icon(Icons.delivery_dining_rounded, color: AppColors.primary, size: 32);
                  final titleRowWidget = Row(
                    children: [
                      Expanded(child: Text(d['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                      if (isBlocked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.all(Radius.circular(8))),
                          child: const Text('Blocked', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  );
                  final subtitleWidget = Text('Phone: ${d['phone']} | Status: ${d['status']}');

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
                              Row(
                                children: [
                                  const Text('Active', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 30,
                                    child: Switch(
                                      value: !isBlocked,
                                      activeThumbColor: Colors.green,
                                      inactiveThumbColor: Colors.red,
                                      inactiveTrackColor: Colors.red[200],
                                      onChanged: (active) {
                                        final updatedList = List<Map<String, dynamic>>.from(state.drivers);
                                        final idx = updatedList.indexWhere((driver) => driver['id'].toString() == d['id'].toString());
                                        if (idx != -1) {
                                          updatedList[idx] = Map<String, dynamic>.from(updatedList[idx])..['is_blocked'] = !active;
                                          _adminBloc.add(SaveDriversEvent(updatedList));
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, color: Colors.teal),
                                    onPressed: () => _showDriverDetails(context, d),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showDriverForm(context, state.drivers, driver: d),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteConfirmation(context, () {
                                      final updatedList = List<Map<String, dynamic>>.from(state.drivers)
                                        ..removeWhere((driver) => driver['id'].toString() == d['id'].toString());
                                      _adminBloc.add(SaveDriversEvent(updatedList));
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
                      title: titleRowWidget,
                      subtitle: subtitleWidget,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.teal),
                            onPressed: () => _showDriverDetails(context, d),
                          ),
                          Switch(
                            value: !isBlocked,
                            activeThumbColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.red[200],
                            onChanged: (active) {
                              final updatedList = List<Map<String, dynamic>>.from(state.drivers);
                              final idx = updatedList.indexWhere((driver) => driver['id'].toString() == d['id'].toString());
                              if (idx != -1) {
                                updatedList[idx] = Map<String, dynamic>.from(updatedList[idx])..['is_blocked'] = !active;
                                _adminBloc.add(SaveDriversEvent(updatedList));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showDriverForm(context, state.drivers, driver: d),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(context, () {
                              final updatedList = List<Map<String, dynamic>>.from(state.drivers)
                                ..removeWhere((driver) => driver['id'].toString() == d['id'].toString());
                              _adminBloc.add(SaveDriversEvent(updatedList));
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

  void _showDriverDetails(BuildContext context, Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Driver Profile Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${driver['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Phone: ${driver['phone']}'),
            const SizedBox(height: 8),
            Text('Status: ${driver['status']}'),
            const SizedBox(height: 8),
            Text('Driver Account Status: ${driver['is_blocked'] == true ? "Blocked" : "Active"}', style: TextStyle(color: driver['is_blocked'] == true ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showDriverForm(BuildContext context, List<Map<String, dynamic>> currentDrivers, {Map<String, dynamic>? driver}) {
    final nameController = TextEditingController(text: driver?.containsKey('name') == true ? driver!['name'] : '');
    final phoneController = TextEditingController(text: driver?.containsKey('phone') == true ? driver!['phone'] : '');
    String status = driver?.containsKey('status') == true ? driver!['status'] : 'available';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              title: Text(driver == null ? 'Add Driver' : 'Edit Driver'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    initialValue: status,
                    items: ['available', 'busy', 'offline'].map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.toUpperCase()),
                        )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateBuilder(() => status = val);
                      }
                    },
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final updatedList = List<Map<String, dynamic>>.from(currentDrivers);
                      if (driver == null) {
                        updatedList.add({
                          'id': (updatedList.length + 1).toString(),
                          'name': nameController.text,
                          'phone': phoneController.text,
                          'status': status,
                          'is_blocked': false,
                        });
                      } else {
                        final idx = updatedList.indexWhere((element) => element['id'].toString() == driver['id'].toString());
                        if (idx != -1) {
                          updatedList[idx] = {
                            'id': driver['id'],
                            'name': nameController.text,
                            'phone': phoneController.text,
                            'status': status,
                            'is_blocked': driver['is_blocked'] ?? false,
                          };
                        }
                      }
                      _adminBloc.add(SaveDriversEvent(updatedList));
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                )
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Analytics & Performance Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  const Text('Revenue Reports (Last 7 Days)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  state.revenueByDay.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Text('No revenue data available.')))
                      : SizedBox(
                          height: 180,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: state.revenueByDay.entries.map((e) {
                              final maxRevenue = state.revenueByDay.values.fold(0.0, (max, val) => val > max ? val : max);
                              final heightPct = maxRevenue > 0 ? e.value / maxRevenue : 0.0;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('\$${e.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                                  Text(e.key.substring(5), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                  const Text('Top Selling Meals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  state.topSellingMeals.isEmpty
                      ? const Center(child: Text('No sales records.'))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.topSellingMeals.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final meal = state.topSellingMeals[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              title: Text(meal['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('Units Sold: ${meal['sales']}'),
                              trailing: Text(
                                '\$${meal['revenue'].toStringAsFixed(2)}',
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

  // -------------------------------------------------------------
  // TAB 8: SYSTEM SETTINGS
  // -------------------------------------------------------------
  Widget _buildSettingsView(AdminLoaded state) {
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
          const Text('System Configurations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      decoration: const InputDecoration(labelText: 'Application Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: feeController,
                      decoration: const InputDecoration(labelText: 'Default Delivery Fee (\$)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Must be valid' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: taxController,
                      decoration: const InputDecoration(labelText: 'Tax Rate (e.g. 0.15 for 15%)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Must be valid' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: currencyController,
                      decoration: const InputDecoration(labelText: 'Currency Settings'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                      child: const Text('Save Settings', style: TextStyle(color: Colors.white)),
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
                  const Text('Broadcast Notification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Send an instant broadcast push notification to all active customer devices.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: promoController,
                    decoration: InputDecoration(
                      hintText: 'Enter notification message here...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (promoController.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Broadcast Notification Sent: "${promoController.text}"')),
                        );
                        promoController.clear();
                      }
                    },
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    label: const Text('Send Broadcast', style: TextStyle(color: Colors.white)),
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
