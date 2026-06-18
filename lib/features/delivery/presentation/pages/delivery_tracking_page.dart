import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../../di/injection_container.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../bloc/delivery_bloc.dart';
import '../bloc/delivery_event.dart';
import '../bloc/delivery_state.dart';

class DeliveryTrackingPage extends StatefulWidget {
  final int orderId;
  const DeliveryTrackingPage({super.key, required this.orderId});

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  late DeliveryBloc _bloc;
  Timer? _locationTimer;
  double _animationStep = 0.0;
  double? _customerLat;
  double? _customerLng;
  
  // Default coordinates (SF fallback)
  final double defaultLat = 37.7749;
  final double defaultLng = -122.4194;

  @override
  void initState() {
    super.initState();
    _bloc = sl<DeliveryBloc>()..add(FetchAssignedOrders());
    _startLocationSimulation();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationSimulation() {
    // Periodically update coordinates every 10 seconds to simulate a moving driver and update database
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_bloc.state is DeliveryLoaded) {
        final state = _bloc.state as DeliveryLoaded;
        final orderIndex = state.assignedOrders.indexWhere((o) => o.id == widget.orderId);
        if (orderIndex != -1) {
          final order = state.assignedOrders[orderIndex];
          if (_customerLat == null) {
            _customerLat = order.latitude ?? defaultLat;
            _customerLng = order.longitude ?? defaultLng;
          }
          final double cLat = _customerLat!;
          final double cLng = _customerLng!;
          final double rLat = cLat - 0.005;
          final double rLng = cLng - 0.005;

          // Increment step from 0.0 (restaurant) to 1.0 (customer destination)
          setState(() {
            _animationStep += 0.1;
            if (_animationStep > 1.0) _animationStep = 1.0;
          });

          // Interpolated coordinates
          final currentLat = rLat + (cLat - rLat) * _animationStep;
          final currentLng = rLng + (cLng - rLng) * _animationStep;

          _bloc.add(UpdateDriverLocation(
            orderId: widget.orderId,
            latitude: currentLat,
            longitude: currentLng,
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: BlocBuilder<DeliveryBloc, DeliveryState>(
          buildWhen: (previous, current) =>
              current is DeliveryLoading || current is DeliveryLoaded || current is DeliveryError,
          builder: (context, state) {
            if (state is DeliveryLoading) {
              return const MapTrackingSkeleton();
            } else if (state is DeliveryLoaded) {
              final orderIndex = state.assignedOrders.indexWhere((o) => o.id == widget.orderId);
              if (orderIndex == -1) {
                return const Center(child: Text('Order not found or completed.'));
              }
              final order = state.assignedOrders[orderIndex];

              if (_customerLat == null) {
                _customerLat = order.latitude ?? defaultLat;
                _customerLng = order.longitude ?? defaultLng;
              }
              final double cLat = _customerLat!;
              final double cLng = _customerLng!;
              final double rLat = cLat - 0.005;
              final double rLng = cLng - 0.005;

              final LatLng restaurantLoc = LatLng(rLat, rLng);
              final LatLng customerLoc = LatLng(cLat, cLng);

              // Driver coordinates interpolated
              final LatLng driverLoc = LatLng(
                rLat + (cLat - rLat) * _animationStep,
                rLng + (cLng - rLng) * _animationStep,
              );

              return Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: driverLoc,
                      initialZoom: 14.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.delievry_app',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [restaurantLoc, customerLoc],
                            color: AppColors.primary,
                            strokeWidth: 5.0,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: restaurantLoc,
                            width: 45,
                            height: 45,
                            child: _buildMapMarker(Icons.restaurant, Colors.orange),
                          ),
                          Marker(
                            point: customerLoc,
                            width: 45,
                            height: 45,
                            child: _buildMapMarker(Icons.location_on_rounded, Colors.red),
                          ),
                          Marker(
                            point: driverLoc,
                            width: 50,
                            height: 50,
                            child: _buildMapMarker(Icons.delivery_dining_rounded, AppColors.primary, isDriver: true),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Back Button Overlay
                  Positioned(
                    top: 40,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),

                  // Bottom ETA Panel
                  _buildEtaPanel(context, order),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMapMarker(IconData icon, Color color, {bool isDriver = false}) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: color, size: isDriver ? 28 : 24),
    );
  }

  Widget _buildEtaPanel(BuildContext context, OrderEntity order) {
    // Dynamic remaining time calculation
    final remainingPercent = 1.0 - _animationStep;
    final int minutesRemaining = (remainingPercent * 15).round();
    final etaText = minutesRemaining > 0 ? '$minutesRemaining mins' : 'Arrived';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timer_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ETA: $etaText',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        (order.status == OrderStatus.picked_up || order.status == OrderStatus.out_for_delivery)
                            ? 'Delivering to customer'
                            : 'Heading to restaurant',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Restaurant: ${order.restaurant.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text('Delivery Location: ${order.deliveryAddress}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _showStatusTransitionDialog(context, order),
                    child: const Text('Update Status', style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppColors.primary.withAlpha(20),
                  child: IconButton(
                    icon: const Icon(Icons.phone, color: AppColors.primary),
                    onPressed: () {
                      context.showInfoToast(
                        title: 'Calling Customer',
                        message: 'Calling customer...',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
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
