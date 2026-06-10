import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection_container.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late CartBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<CartBloc>()..add(FetchCart());
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
          title: const Text('My Cart', style: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () => _bloc.add(ClearCart()),
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
                          onQuantityChanged: (q) => _bloc.add(
                            UpdateItemQuantity(lineId: state.cart.items[index].id, quantity: q),
                          ),
                          onRemoved: () => _bloc.add(RemoveItemFromCart(state.cart.items[index].id)),
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
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Looks like you haven\'t added anything yet', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.go('/home'),
            child: const Text('Go Shopping', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
