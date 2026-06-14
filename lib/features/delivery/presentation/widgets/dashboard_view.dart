import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
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
    
    // Filter active orders (heading_to_restaurant, picked_up, out_for_delivery)
    final activeOrders = state.assignedOrders.where((o) => 
      o.status == OrderStatus.heading_to_restaurant ||
      o.status == OrderStatus.picked_up ||
      o.status == OrderStatus.out_for_delivery
    ).toList();

    // Filter newly assigned orders (pending or preparing)
    final newAssignments = state.assignedOrders.where((o) =>
      o.status == OrderStatus.pending ||
      o.status == OrderStatus.preparing
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

  double _calculateDistance(double? lat1, double? lng1, double? lat2, double? lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return 3.5; // Fallback default distance
    }
    try {
      const distance = Distance();
      final double meter = distance.as(LengthUnit.Meter, LatLng(lat1, lng1), LatLng(lat2, lng2));
      return meter / 1000.0;
    } catch (_) {
      return 3.5;
    }
  }

  Widget _buildNewAssignmentCard(BuildContext context, OrderEntity order) {
    final distanceKm = _calculateDistance(
      state.driver.latitude,
      state.driver.longitude,
      order.latitude,
      order.longitude,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderRequestBottomSheet(context, order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delivery_dining_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.restaurant.name,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.deliveryAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.restaurant.deliveryFee.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderRequestBottomSheet(BuildContext context, OrderEntity order) {
    final distanceKm = _calculateDistance(
      state.driver.latitude,
      state.driver.longitude,
      order.latitude,
      order.longitude,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Header title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Request #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Payout display
              Center(
                child: Column(
                  children: [
                    const Text(
                      'ESTIMATED PAYOUT',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${order.restaurant.deliveryFee.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pickup / Dropoff Timeline
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.radio_button_checked, color: Colors.orange, size: 20),
                      Container(
                        width: 2,
                        height: 50,
                        color: Colors.grey[300],
                      ),
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pickup Restaurant details
                        Text(
                          'PICKUP - ${order.restaurant.name}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.restaurant.address,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),
                        // Dropoff Customer details
                        const Text(
                          'DELIVER TO',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.deliveryAddress,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Trip details row (Distance / Items count)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRequestDetailTile(
                    Icons.directions_run_rounded,
                    'Distance',
                    '${distanceKm.toStringAsFixed(1)} km',
                  ),
                  _buildRequestDetailTile(
                    Icons.shopping_bag_rounded,
                    'Items',
                    '${order.items.length} items',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Items details list
              if (order.items.isNotEmpty) ...[
                const Text(
                  'Items Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: order.items.length,
                    itemBuilder: (context, idx) {
                      final item = order.items[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.productName)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Notes section if any
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Note: ${order.notes}',
                          style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        BlocProvider.of<DeliveryBloc>(context).add(
                          UpdateDeliveryStatus(orderId: order.id, status: 'preparing'),
                        );
                      },
                      child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        BlocProvider.of<DeliveryBloc>(context).add(
                          AcceptDeliveryEvent(orderId: order.id),
                        );
                      },
                      child: const Text('Accept Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestDetailTile(IconData icon, String title, String val) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        Text(
          val,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
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
    final List<Widget> tiles = [];
    final status = order.status;

    if (status == OrderStatus.preparing) {
      tiles.add(_buildTransitionTile(context, 'Heading to Restaurant', 'heading_to_restaurant', order));
    } else if (status == OrderStatus.heading_to_restaurant) {
      tiles.add(_buildTransitionTile(context, 'Food Picked Up', 'picked_up', order));
      tiles.add(_buildTransitionTile(context, 'Reject Assignment', 'preparing', order));
    } else if (status == OrderStatus.picked_up) {
      tiles.add(_buildTransitionTile(context, 'Out for Delivery', 'out_for_delivery', order));
      tiles.add(_buildTransitionTile(context, 'Failed Delivery', 'failed', order));
    } else if (status == OrderStatus.out_for_delivery) {
      tiles.add(_buildTransitionTile(context, 'Mark as Delivered', 'delivered', order));
      tiles.add(_buildTransitionTile(context, 'Failed Delivery', 'failed', order));
    }

    // Always allow cancellation if not completed
    if (status != OrderStatus.delivered && status != OrderStatus.failed && status != OrderStatus.cancelled) {
      tiles.add(_buildTransitionTile(context, 'Cancel Order', 'cancelled', order));
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Transition Status for #${order.id}'),
          content: tiles.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No further transitions possible for this order.'),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: tiles,
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
