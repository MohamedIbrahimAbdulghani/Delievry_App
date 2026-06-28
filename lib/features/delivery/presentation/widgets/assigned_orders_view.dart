import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../bloc/delivery_bloc.dart';
import '../bloc/delivery_event.dart';
import '../bloc/delivery_state.dart';
import 'package:delievry_app/l10n/app_localizations.dart';
import '../../../../core/utils/order_status_l10n.dart';
import '../../../../core/utils/data_localization_helper.dart';

class AssignedOrdersView extends StatefulWidget {
  final DeliveryLoaded state;

  const AssignedOrdersView({super.key, required this.state});

  @override
  State<AssignedOrdersView> createState() => _AssignedOrdersViewState();
}

class _AssignedOrdersViewState extends State<AssignedOrdersView> {
  String _searchQuery = '';
  OrderStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    // Filter out completed history (delivered, failed, cancelled) for this active screen
    final activeStatusList = [
      OrderStatus.pending,
      OrderStatus.preparing,
      OrderStatus.heading_to_restaurant,
      OrderStatus.picked_up,
      OrderStatus.out_for_delivery,
    ];

    final filtered = widget.state.assignedOrders.where((order) {
      final matchesSearch = order.id.toString().contains(_searchQuery) ||
          order.restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.deliveryAddress.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _filterStatus == null 
          ? activeStatusList.contains(order.status)
          : order.status == _filterStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Shipments',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.searchOrders ?? 'Search by ID, restaurant, address...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 12),
          // Horizontal status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Active', null),
                const SizedBox(width: 8),
                _buildFilterChip('Preparing', OrderStatus.preparing),
                const SizedBox(width: 8),
                _buildFilterChip('Heading to Rest', OrderStatus.heading_to_restaurant),
                const SizedBox(width: 8),
                _buildFilterChip('Picked Up', OrderStatus.picked_up),
                const SizedBox(width: 8),
                _buildFilterChip('Out for Delivery', OrderStatus.out_for_delivery),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            '${AppLocalizations.of(context)?.orderLabel ?? "Order"} #${DataLocalizationHelper.formatNumber(context, order.id)} - ${order.restaurant.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${AppLocalizations.of(context)?.statusLabel ?? "Status"}: ${order.status.localize(context)} | ${AppLocalizations.of(context)?.deliveryFee ?? "Fee:"} ${DataLocalizationHelper.formatCurrency(context, order.restaurant.deliveryFee)}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order.status.localize(context),
                              style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          onTap: () => _showOrderDetailsSheet(context, order),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, OrderStatus? status) {
    final isSelected = _filterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() => _filterStatus = status);
        }
      },
      selectedColor: AppColors.primary.withAlpha(50),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.heading_to_restaurant:
        return Colors.teal;
      case OrderStatus.picked_up:
        return Colors.purple;
      case OrderStatus.out_for_delivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.failed:
        return Colors.redAccent;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No matching orders found.',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsSheet(BuildContext context, OrderEntity order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Restaurant Info
                  Text(AppLocalizations.of(context)?.restaurantDetails ?? 'Restaurant Details', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('${AppLocalizations.of(context)?.name ?? "Name"}: ${order.restaurant.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${AppLocalizations.of(context)?.phoneNumber ?? "Phone"}: ${order.restaurant.phone}'),
                  Text('${AppLocalizations.of(context)?.address ?? "Address"}: ${order.restaurant.address}'),
                  const Divider(height: 24),

                  // Customer Info & Delivery Location
                  const Text('Delivery Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Address: ${order.deliveryAddress}'),
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('${AppLocalizations.of(context)?.notes ?? "Delivery Notes"}: ${order.notes}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.redAccent)),
                  ],
                  const Divider(height: 24),

                  // Items
                  const Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.productName} (x${DataLocalizationHelper.formatNumber(context, item.quantity)})'),
                            Text(DataLocalizationHelper.formatCurrency(context, item.unitPrice * item.quantity)),
                          ],
                        ),
                      )),
                  const Divider(height: 24),

                  // Actions
                  if (order.status == OrderStatus.pending || order.status == OrderStatus.preparing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (order.status == OrderStatus.preparing) {
                            BlocProvider.of<DeliveryBloc>(context).add(
                              AcceptDeliveryEvent(orderId: order.id),
                            );
                          } else {
                            BlocProvider.of<DeliveryBloc>(context).add(
                              UpdateDeliveryStatus(orderId: order.id, status: 'heading_to_restaurant'),
                            );
                          }
                        },
                        child: Text(AppLocalizations.of(context)?.acceptDelivery ?? 'Accept Delivery', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map_rounded, color: Colors.white),
                            label: Text(AppLocalizations.of(context)?.trackNavigate ?? 'Track / Navigate', style: const TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.push('/delivery/tracking/${order.id}');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showStatusTransitionDialog(context, order);
                            },
                            child: Text(AppLocalizations.of(context)?.updateStatus ?? 'Update Status', style: const TextStyle(color: AppColors.primary)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
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
              child: Text(AppLocalizations.of(context)?.close ?? 'Close'),
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
