import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_card.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(FetchCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(AppLocalizations.of(context)?.myCart ?? 'My Cart', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => context.read<CartBloc>().add(ClearCart()),
            child: Text(AppLocalizations.of(context)?.clearBtn ?? 'Clear', style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const ListSkeleton(itemCount: 3, height: 100);
          } else if (state is CartLoaded) {
            if (state.cart.items.isEmpty) {
              return _buildEmptyCart();
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.cart.items.length,
                    itemBuilder: (context, index) {
                      return CartItemTile(
                        item: state.cart.items[index],
                        onQuantityChanged: (q) => context.read<CartBloc>().add(
                          UpdateItemQuantity(lineId: state.cart.items[index].id, quantity: q),
                        ),
                        onRemoved: () => context.read<CartBloc>().add(RemoveItemFromCart(state.cart.items[index].id)),
                      );
                    },
                  ),
                ),
                CartSummaryCard(
                  cart: state.cart,
                  onCheckout: () => context.push('/checkout'),
                ),
              ],
            );
          } else if (state is CartError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)?.cartEmpty ?? 'Your cart is empty', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)?.addItemsToCart ?? 'Looks like you haven\'t added anything yet', style: TextStyle(color: Colors.grey[500]), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                minimumSize: const Size(180, 48),
              ),
              child: Text(
                AppLocalizations.of(context)?.goShopping ?? 'Go Shopping',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
