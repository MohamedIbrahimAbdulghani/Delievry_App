import 'package:flutter/material.dart';
import '../../features/orders/domain/entities/order_entity.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

extension OrderStatusL10n on OrderStatus {
  String localize(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (this) {
      case OrderStatus.pending:
        return l?.statusPending ?? 'Pending';
      case OrderStatus.preparing:
        return l?.statusPreparing ?? 'Preparing';
      case OrderStatus.heading_to_restaurant:
        return l?.statusHeadingToRestaurant ?? 'Heading to Restaurant';
      case OrderStatus.picked_up:
        return l?.statusPickedUp ?? 'Picked Up';
      case OrderStatus.out_for_delivery:
        return l?.statusOutForDelivery ?? 'Out for Delivery';
      case OrderStatus.delivered:
        return l?.statusDelivered ?? 'Delivered';
      case OrderStatus.failed:
        return l?.statusFailed ?? 'Failed';
      case OrderStatus.cancelled:
        return l?.statusCancelled ?? 'Cancelled';
    }
  }
}
