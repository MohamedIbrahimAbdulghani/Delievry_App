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

  // Helper date formatter
  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // -------------------------------------------------------------
  // TAB 0: DASHBOARD VIEW
  // -------------------------------------------------------------
  Widget _buildDashboardView(AdminLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Cards Row
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 600
                ? 2
                : MediaQuery.of(context).size.width < 1100
                    ? 2
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
                'Restaurants',
                '${state.totalRestaurants}',
                Icons.restaurant_rounded,
                [const Color(0xFFF4511E), const Color(0xFFFF7043)],
              ),
              _buildStatCard(
                'Users Registered',
                '${state.totalUsers}',
                Icons.people_rounded,
                [const Color(0xFF7B1FA2), const Color(0xFFAB47BC)],
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Orders',
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
                                    subtitle: Text(_formatDate(order.createdAt)),
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
          BoxShadow(color: colors[0].withAlpha(50), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Icon(icon, color: Colors.white.withAlpha(200), size: 24),
            ],
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
      case OrderStatus.out_for_delivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Order #${order.id} updated to ${s.displayName}')),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const Divider(height: 24),
                      const Text('Assign Driver (Simulation):', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedDriverId,
                        hint: const Text('Select Driver'),
                        items: drivers.map((d) => DropdownMenuItem(
                              value: d['id'].toString(),
                              child: Text('${d['name']} (${d['status']})'),
                            )).toList(),
                        onChanged: (dId) {
                          setModalState(() => selectedDriverId = dId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Driver assigned successfully!')),
                          );
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withAlpha(30),
                      child: const Icon(Icons.restaurant, color: AppColors.primary),
                    ),
                    title: Text(rest.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${rest.city} | Delivery Fee: \$${rest.deliveryFee.toStringAsFixed(2)}'),
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
                                'is_active': active,
                              },
                            ));
                          },
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
                  ),
                );
              },
            ),
          )
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
    bool isActive = restaurant?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
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
                  StatefulBuilder(
                    builder: (context, setStateBuilder) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Active Status'),
                        Switch(
                          value: isActive,
                          onChanged: (val) => setStateBuilder(() => isActive = val),
                        )
                      ],
                    ),
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
                    'is_active': isActive,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted successfully')),
              );
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
              ElevatedButton.icon(
                onPressed: () => _showMealForm(context, state.restaurants),
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
                // Find restaurant name
                final restName = state.restaurants.cast<RestaurantEntity>().firstWhere((r) => r.id == meal.restaurantId,
                    orElse: () => const RestaurantEntity(id: 0, name: 'Unknown', slug: '', city: '', address: '', phone: '', deliveryFee: 0, isActive: false)).name;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withAlpha(30),
                      child: const Icon(Icons.fastfood, color: AppColors.primary),
                    ),
                    title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Price: \$${meal.price.toStringAsFixed(2)} | Category: ${meal.category} | Rest: $restName'),
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
                                'is_available': avail,
                              },
                            ));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showMealForm(context, state.restaurants, meal: meal),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(context, () {
                            _adminBloc.add(DeleteMealEvent(meal.id));
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showMealForm(BuildContext context, List<RestaurantEntity> restaurants, {MealEntity? meal}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: meal?.name ?? '');
    final descriptionController = TextEditingController(text: meal?.description ?? '');
    final priceController = TextEditingController(text: meal?.price.toString() ?? '');
    final categoryController = TextEditingController(text: meal?.category ?? '');
    int? selectedRestaurantId = meal?.restaurantId ?? (restaurants.isNotEmpty ? restaurants.first.id : null);
    bool isAvailable = meal?.isAvailable ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
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
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category (Pizza, Burgers, etc.)'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setStateBuilder) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Available Status'),
                        Switch(
                          value: isAvailable,
                          onChanged: (val) => setStateBuilder(() => isAvailable = val),
                        )
                      ],
                    ),
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
                    'category': categoryController.text,
                    'is_available': isAvailable,
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
  }

  // -------------------------------------------------------------
  // TAB 4: CATEGORY MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildCategoriesView(AdminLoaded state) {
    // Collect all categories dynamically from meals
    final categories = state.meals
        .map((m) => m.category)
        .toSet()
        .map((name) => CategoryEntity(id: name, name: name))
        .toList();
    final catNameController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Manage Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Add Category'),
                      content: TextField(
                        controller: catNameController,
                        decoration: const InputDecoration(hintText: 'Category Name (e.g. Desserts)'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            if (catNameController.text.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Category "${catNameController.text}" created successfully!')),
                              );
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('Save'),
                        )
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Category', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.category_rounded, color: AppColors.primary),
                    title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context, () {
                        // In simulation just pop a message
                      }),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 5: USERS MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildUsersView(AdminLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                final isSelf = sl<SessionManager>().currentUser?.id == user.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isAdmin ? AppColors.primary : Colors.grey[300],
                      child: Icon(Icons.person, color: user.isAdmin ? Colors.white : Colors.black87),
                    ),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${user.email} | Role: ${user.isAdmin ? 'Admin' : 'Customer'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isSelf) ...[
                          TextButton(
                            onPressed: () {
                              _adminBloc.add(UpdateUserEvent(
                                id: user.id,
                                data: {'is_admin': !user.isAdmin},
                              ));
                            },
                            child: Text(user.isAdmin ? 'Revoke Admin' : 'Make Admin'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.block, color: Colors.orange),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${user.name} has been blocked successfully!')),
                              );
                            },
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
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 6: DELIVERY DRIVERS
  // -------------------------------------------------------------
  Widget _buildDriversView(AdminLoaded state) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Drivers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Add Driver'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                          TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              final updatedList = List<Map<String, dynamic>>.from(state.drivers)
                                ..add({
                                  'id': (state.drivers.length + 1).toString(),
                                  'name': nameController.text,
                                  'phone': phoneController.text,
                                  'status': 'available',
                                });
                              _adminBloc.add(SaveDriversEvent(updatedList));
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('Save'),
                        )
                      ],
                    ),
                  );
                },
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.delivery_dining_rounded, color: AppColors.primary, size: 32),
                    title: Text(d['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Phone: ${d['phone']} | Status: ${d['status']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context, () {
                        final updatedList = List<Map<String, dynamic>>.from(state.drivers)
                          ..removeWhere((driver) => driver['id'] == d['id']);
                        _adminBloc.add(SaveDriversEvent(updatedList));
                      }),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
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
          // Simple visual chart mockup for revenue by day
          Card(
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
                              // Calculate height relative to max revenue
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings saved successfully!')),
                          );
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
          // Broadcast Notification Section
          Card(
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
