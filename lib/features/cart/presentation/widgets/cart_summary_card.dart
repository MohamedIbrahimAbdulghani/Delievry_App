import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/cart_entity.dart';
import 'package:delievry_app/l10n/app_localizations.dart';
import '../../../../core/utils/data_localization_helper.dart';

class CartSummaryCard extends StatelessWidget {
  final CartEntity cart;
  final VoidCallback onCheckout;

  const CartSummaryCard({
    super.key,
    required this.cart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(context, AppLocalizations.of(context)?.subtotal ?? 'Subtotal', DataLocalizationHelper.formatCurrency(context, cart.subtotal)),
          const SizedBox(height: 8),
          _buildRow(context, AppLocalizations.of(context)?.deliveryFee ?? 'Delivery Fee', DataLocalizationHelper.formatCurrency(context, cart.deliveryFee)),
          const SizedBox(height: 8),
          _buildRow(context, AppLocalizations.of(context)?.tax ?? 'Tax', DataLocalizationHelper.formatCurrency(context, cart.tax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: AppColors.outline),
          ),
          _buildRow(context, AppLocalizations.of(context)?.total ?? 'Total', DataLocalizationHelper.formatCurrency(context, cart.total), isTotal: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onCheckout,
              child: Text(
                AppLocalizations.of(context)?.checkout ?? 'Checkout',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
            color: isTotal ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
