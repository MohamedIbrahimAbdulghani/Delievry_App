import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
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
  Timer? _pollTimer;
  OrderEntity? _lastOrder;

  @override
  void initState() {
    super.initState();
    _bloc = sl<OrdersBloc>()..add(FetchOrderDetails(widget.orderId));
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _bloc.add(FetchOrderDetails(widget.orderId, showLoading: false));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        body: BlocConsumer<OrdersBloc, OrdersState>(
          listener: (context, state) {
            if (state is OrdersError && _lastOrder != null) {
              context.showErrorToast(
                title: 'Tracking Error',
                message: 'Failed to update tracking: ${state.message}',
              );
            }
          },
          builder: (context, state) {
            if (state is OrderDetailsLoaded) {
              _lastOrder = state.order;
            }

            if (state is OrdersLoading && _lastOrder == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (_lastOrder != null) {
              final order = _lastOrder!;
              debugPrint('Order details loaded: ID: ${order.id}, Lat: ${order.latitude}, Lng: ${order.longitude}, DriverLat: ${order.driverLatitude}');
              
              final double defaultLat = 37.7749;
              final double defaultLng = -122.4194;
              
              final double custLat = order.latitude ?? defaultLat;
              final double custLng = order.longitude ?? defaultLng;
              final LatLng deliveryLocation = LatLng(custLat, custLng);

              final double drLat = (order.driverLatitude != null && order.driverLatitude != 0)
                  ? order.driverLatitude!
                  : (custLat - 0.005);
              final double drLng = (order.driverLongitude != null && order.driverLongitude != 0)
                  ? order.driverLongitude!
                  : (custLng - 0.005);
              final LatLng driverLocation = LatLng(drLat, drLng);

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
            } else if (state is OrdersError && _lastOrder == null) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTrackingInfo(OrderEntity order) {
    final status = order.status;
    String statusTitle = 'Order Submitted';
    String statusDesc = 'Waiting for restaurant approval.';
    double progress = 0.125;
    IconData statusIcon = Icons.receipt_long_rounded;

    switch (status) {
      case OrderStatus.pending:
        statusTitle = 'Order Submitted';
        statusDesc = 'Waiting for restaurant approval.';
        progress = 0.125;
        statusIcon = Icons.receipt_long_rounded;
        break;
      case OrderStatus.preparing:
        statusTitle = 'Preparing your order';
        statusDesc = 'The restaurant is preparing your food.';
        progress = 0.25;
        statusIcon = Icons.restaurant_rounded;
        break;
      case OrderStatus.heading_to_restaurant:
        statusTitle = 'Heading to Restaurant';
        statusDesc = 'A delivery partner is heading to pick up your order.';
        progress = 0.375;
        statusIcon = Icons.directions_run_rounded;
        break;
      case OrderStatus.picked_up:
        statusTitle = 'Order Picked Up';
        statusDesc = 'Driver has collected your food and is preparing delivery.';
        progress = 0.5;
        statusIcon = Icons.local_shipping_rounded;
        break;
      case OrderStatus.out_for_delivery:
        statusTitle = 'Out for Delivery';
        statusDesc = 'Driver is on the way to your location.';
        progress = 0.75;
        statusIcon = Icons.delivery_dining_rounded;
        break;
      case OrderStatus.delivered:
        statusTitle = 'Order Delivered';
        statusDesc = 'Enjoy your meal!';
        progress = 1.0;
        statusIcon = Icons.check_circle_rounded;
        break;
      case OrderStatus.failed:
        statusTitle = 'Delivery Failed';
        statusDesc = 'There was an issue delivering your order.';
        progress = 1.0;
        statusIcon = Icons.error_outline_rounded;
        break;
      case OrderStatus.cancelled:
        statusTitle = 'Order Cancelled';
        statusDesc = 'This order was cancelled.';
        progress = 1.0;
        statusIcon = Icons.cancel_outlined;
        break;
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
                CircleAvatar(
                  radius: 24,
                  backgroundImage: order.driver?.imageUrl != null
                      ? NetworkImage(order.driver!.imageUrl!)
                      : const NetworkImage('https://i.pravatar.cc/150?u=driver'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.driver?.name ?? 'Driver Captain', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Delivery Partner', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                 IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                  onPressed: () async {
                    if (order.driver == null ||
                        order.driver!.phone == null ||
                        order.driver!.phone!.trim().isEmpty) {
                      context.showWarningToast(
                        title: 'Driver Unavailable',
                        message: 'Driver information is not available yet.',
                      );
                      return;
                    }
                    final phone = order.driver!.phone!.trim();
                    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                    try {
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      } else {
                        if (mounted) {
                          context.showErrorToast(
                            title: 'Call Error',
                            message: 'Could not open phone dialer.',
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        context.showErrorToast(
                          title: 'Call Error',
                          message: 'Error opening dialer: $e',
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
