import 'package:flutter/material.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: _getColor(),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.confirmed: return Colors.blueAccent;
      case OrderStatus.preparing: return Colors.blue;
      case OrderStatus.out_for_delivery: return Colors.purple;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
    }
  }
}
