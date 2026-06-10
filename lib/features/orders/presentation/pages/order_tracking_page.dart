import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class OrderTrackingPage extends StatefulWidget {
  final int orderId;
  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late OrdersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<OrdersBloc>()..add(FetchOrderDetails(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        body: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is OrderDetailsLoaded) {
              final order = state.order;
              debugPrint('Order details loaded: ID: ${order.id}, Lat: ${order.latitude}, Lng: ${order.longitude}');
              
              // Fallback to San Francisco default coordinates if GPS is null/zero
              final double defaultLat = 37.7749;
              final double defaultLng = -122.4194;
              
              final double lat = (order.latitude != null && order.latitude != 0) ? order.latitude! : defaultLat;
              final double lng = (order.longitude != null && order.longitude != 0) ? order.longitude! : defaultLng;
              
              final LatLng driverLocation = LatLng(lat, lng);
              // Slight offset to represent destination address marker
              final LatLng deliveryLocation = LatLng(lat + 0.003, lng + 0.003);

              return Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: driverLocation,
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
                            points: [driverLocation, deliveryLocation],
                            color: AppColors.primary,
                            strokeWidth: 5.0,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: driverLocation,
                            width: 50,
                            height: 50,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Icon(
                                Icons.delivery_dining_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                          ),
                          Marker(
                            point: deliveryLocation,
                            width: 50,
                            height: 50,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.red,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // App Bar Overlay
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
                  _buildTrackingInfo(order),
                ],
              );
            } else if (state is OrdersError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTrackingInfo(OrderEntity order) {
    debugPrint('Order status: ${order.status}');
    final status = order.status.toString().split('.').last.toLowerCase();
    String statusTitle = 'Preparing your order';
    String statusDesc = 'The restaurant is preparing your food.';
    double progress = 0.3;
    IconData statusIcon = Icons.restaurant;

    if (status == 'picked_up' || status == 'on_the_way' || status == 'out_for_delivery') {
      statusTitle = 'Order is on the way';
      statusDesc = 'Your delivery partner is heading to you.';
      progress = 0.7;
      statusIcon = Icons.delivery_dining;
    } else if (status == 'delivered' || status == 'completed') {
      statusTitle = 'Order Delivered';
      statusDesc = 'Enjoy your meal!';
      progress = 1.0;
      statusIcon = Icons.check_circle;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  child: Icon(statusIcon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(statusDesc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: AppColors.primary,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=driver'),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mohamed Ibrahim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Delivery Partner', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
