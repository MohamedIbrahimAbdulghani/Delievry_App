import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/cart_entity.dart';

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
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildRow('Delivery Fee', '\$${cart.deliveryFee.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildRow('Tax', '\$${cart.tax.toStringAsFixed(2)}'),
          const Divider(height: 24, color: AppColors.outline),
          _buildRow('Total', '\$${cart.total.toStringAsFixed(2)}', isTotal: true),
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
              child: const Text(
                'Checkout',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
            color: isTotal ? AppColors.onBackground : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primary : AppColors.onBackground,
          ),
        ),
      ],
    );
  }
}
