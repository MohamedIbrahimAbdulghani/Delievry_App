import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../../di/injection_container.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../../domain/entities/order_entity.dart';
import '../widgets/order_status_badge.dart';
import 'package:delievry_app/l10n/app_localizations.dart';
import '../../../../core/utils/data_localization_helper.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(AppLocalizations.of(context)?.orderDetails ?? 'Order Details', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        ),
        body: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const OrderDetailsSkeleton();
            } else if (state is OrderDetailsLoaded) {
              final order = state.order;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantCard(order),
                    const SizedBox(height: 16),
                    _buildItemsList(order),
                    const SizedBox(height: 16),
                    _buildPaymentSummary(order),
                    const SizedBox(height: 16),
                    _buildDeliveryInfo(order),
                  ],
                ),
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

  Widget _buildRestaurantCard(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              order.restaurant.imageUrl ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, color: Theme.of(context).colorScheme.surface),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.restaurant.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
                Text(order.restaurant.city, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
              ],
            ),
          ),
          OrderStatusBadge(status: order.status),
        ],
      ),
    );
  }

  Widget _buildItemsList(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)?.items ?? 'Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text('${DataLocalizationHelper.formatNumber(context, item.quantity)}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: Text(item.productName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                Text(DataLocalizationHelper.formatCurrency(context, item.unitPrice), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildRow(AppLocalizations.of(context)?.subtotal ?? 'Subtotal', DataLocalizationHelper.formatCurrency(context, order.totalAmount - 5.0), context),
          const SizedBox(height: 8),
          _buildRow(AppLocalizations.of(context)?.deliveryFee ?? 'Delivery Fee', DataLocalizationHelper.formatCurrency(context, 5.0), context),
          const Divider(height: 24),
          _buildRow(AppLocalizations.of(context)?.total ?? 'Total', DataLocalizationHelper.formatCurrency(context, order.totalAmount), context, isBold: true),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(dynamic order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)?.deliveryInfo ?? 'Delivery Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          Text('${AppLocalizations.of(context)?.deliveryAddress ?? 'Address'}:', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
          Text(order.deliveryAddress, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
          if (order.notes != null) ...[
            const SizedBox(height: 12),
            Text('${AppLocalizations.of(context)?.notes ?? 'Notes'}:', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
            Text(order.notes!, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
          ],
          if (order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled &&
              order.status != OrderStatus.failed) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/track-order/${order.id}'),
                icon: const Icon(Icons.location_on_outlined, color: Colors.white),
                label: Text(AppLocalizations.of(context)?.trackOrder ?? 'Track My Order', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, BuildContext context, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Theme.of(context).colorScheme.onSurface)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isBold ? AppColors.primary : Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}
