import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/events/order_events.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../../domain/entities/order_entity.dart';
import '../widgets/order_status_badge.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> with SingleTickerProviderStateMixin {
  late OrdersBloc _bloc;
  late TabController _tabController;
  StreamSubscription? _orderEventSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = sl<OrdersBloc>()..add(FetchOrders());
    _tabController = TabController(length: 2, vsync: this);
    _orderEventSubscription = sl<OrderEventBus>().stream.listen((event) {
      _bloc.add(FetchOrders());
    });
  }

  @override
  void dispose() {
    _orderEventSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('My Orders', style: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Active Orders'),
              Tab(text: 'Past Orders'),
            ],
          ),
        ),
        body: BlocConsumer<OrdersBloc, OrdersState>(
          listener: (context, state) {
            if (state is ReorderSuccess) {
              context.showSuccessToast(
                title: 'Order Recreated',
                message: 'Order recreated in cart successfully!',
              );
              context.read<CartBloc>().add(FetchCart());
              _bloc.add(FetchOrders());
              context.go('/cart');
            } else if (state is OrdersError) {
              context.showErrorToast(
                title: 'Order Error',
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            if (state is OrdersLoading || state is OrdersInitial) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is OrdersLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(state.orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList()),
                  _buildOrdersList(state.orders.where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled).toList()),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList(List orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No orders found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () => context.push('/order-details/${order.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order.restaurant.imageUrl ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: Colors.grey[200]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${order.items.length} items • \$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _bloc.add(ReorderEvent(order.id)),
                          child: const Text('Reorder', style: TextStyle(color: AppColors.primary)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () => context.push('/order-details/${order.id}'), child: const Text('Details')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
