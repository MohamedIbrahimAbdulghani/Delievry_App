import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../bloc/delivery_bloc.dart';
import '../bloc/delivery_event.dart';
import '../bloc/delivery_state.dart';

class DashboardView extends StatelessWidget {
  final DeliveryLoaded state;

  const DashboardView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final earnings = state.earnings;
    
    // Filter active orders (accepted, heading_to_restaurant, picked_up, on_the_way)
    final activeOrders = state.assignedOrders.where((o) => 
      o.status == OrderStatus.accepted ||
      o.status == OrderStatus.heading_to_restaurant ||
      o.status == OrderStatus.picked_up ||
      o.status == OrderStatus.on_the_way
    ).toList();

    // Filter newly assigned orders (confirmed / pending)
    final newAssignments = state.assignedOrders.where((o) =>
      o.status == OrderStatus.confirmed ||
      o.status == OrderStatus.pending
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Profile & Status Header
          _buildHeader(context),
          const SizedBox(height: 20),

          // Statistics Grid
          _buildStatsGrid(earnings),
          const SizedBox(height: 24),

          // Active Order Section
          if (activeOrders.isNotEmpty) ...[
            const Text(
              'Active Delivery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onBackground),
            ),
            const SizedBox(height: 12),
            ...activeOrders.map((order) => _buildActiveOrderCard(context, order)),
            const SizedBox(height: 24),
          ],

          // New Assignments Section
          const Text(
            'New Assigned Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onBackground),
          ),
          const SizedBox(height: 12),
          if (newAssignments.isEmpty)
            _buildEmptyAssignmentsCard()
          else
            ...newAssignments.map((order) => _buildNewAssignmentCard(context, order)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final driver = state.driver;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: driver.latitude != null 
                ? const NetworkImage('https://i.pravatar.cc/150?u=driver')
                : null,
            backgroundColor: AppColors.primary.withAlpha(30),
            child: driver.latitude == null 
                ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${driver.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  driver.isOnline ? 'Online & Available' : 'Offline',
                  style: TextStyle(
                    color: driver.isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: driver.isOnline,
            activeThumbColor: Colors.green,
            onChanged: (val) {
              BlocProvider.of<DeliveryBloc>(context).add(ToggleAvailability(isOnline: val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> earnings) {
    final todayEarnings = earnings['today_earnings'] ?? 0.0;
    final todayCount = earnings['today_deliveries'] ?? 0;
    final totalCount = earnings['total_deliveries'] ?? 0;

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _buildStatItem(
          'Today\'s Pay',
          '\$${todayEarnings.toStringAsFixed(2)}',
          Icons.monetization_on_rounded,
          const Color(0xFF43A047),
        ),
        _buildStatItem(
          'Today\'s Trips',
          '$todayCount',
          Icons.local_shipping_rounded,
          const Color(0xFF1E88E5),
        ),
        _buildStatItem(
          'Total Trips',
          '$totalCount',
          Icons.history_rounded,
          const Color(0xFF8E24AA),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(BuildContext context, OrderEntity order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Restaurant: ${order.restaurant.name}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              'Pickup: ${order.restaurant.address}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Deliver To: ${order.deliveryAddress}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${order.notes}',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.redAccent, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map_rounded, color: Colors.white),
                    label: const Text('Navigate', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.push('/delivery/tracking/${order.id}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showStatusTransitionDialog(context, order),
                    child: const Text('Update Status', style: TextStyle(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewAssignmentCard(BuildContext context, OrderEntity order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          'Order #${order.id} - ${order.restaurant.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To: ${order.deliveryAddress}', maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('Payout: \$${order.restaurant.deliveryFee.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 30),
              onPressed: () {
                BlocProvider.of<DeliveryBloc>(context).add(
                  UpdateDeliveryStatus(orderId: order.id, status: 'accepted'),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel_rounded, color: Colors.red, size: 30),
              onPressed: () {
                // Reject assignment simulation (unassign driver)
                BlocProvider.of<DeliveryBloc>(context).add(
                  UpdateDeliveryStatus(orderId: order.id, status: 'confirmed'), // reset status/assign
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAssignmentsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: const Column(
        children: [
          Icon(Icons.assignment_turned_in_rounded, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'No pending assigned orders.',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          ),
          Text(
            'New orders will appear here as they are assigned.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showStatusTransitionDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Transition Status for #${order.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTransitionTile(context, 'Heading to Restaurant', 'heading_to_restaurant', order),
              _buildTransitionTile(context, 'Food Picked Up', 'picked_up', order),
              _buildTransitionTile(context, 'On the Way', 'on_the_way', order),
              _buildTransitionTile(context, 'Mark as Delivered', 'delivered', order),
              _buildTransitionTile(context, 'Failed Delivery', 'failed', order),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransitionTile(BuildContext context, String title, String status, OrderEntity order) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: () {
        Navigator.pop(context);
        BlocProvider.of<DeliveryBloc>(context).add(
          UpdateDeliveryStatus(orderId: order.id, status: status),
        );
      },
    );
  }
}
