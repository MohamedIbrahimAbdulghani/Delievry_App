import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/restaurant_detail_entity.dart';

class RestaurantMenuTabs extends StatelessWidget {
  final RestaurantDetailEntity restaurant;

  const RestaurantMenuTabs({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    if (restaurant.products.isEmpty) {
      return const Center(child: Text('No items available in the menu.'));
    }

    final categories = restaurant.categories;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        final products = restaurant.products.where((p) => p.category == category).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
            ),
            ...products.map((product) => _buildProductItem(context, product)),
          ],
        );
      },
    );
  }

  Widget _buildProductItem(BuildContext context, dynamic product) {
    return GestureDetector(
      onTap: () => context.push('/product-details/${product.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      BlocBuilder<CartBloc, CartState>(
                        builder: (context, state) {
                          CartItemEntity? cartItem;
                          if (state is CartLoaded) {
                            for (var item in state.cart.items) {
                              if (item.product.id == product.id) {
                                cartItem = item;
                                break;
                              }
                            }
                          }

                          if (cartItem == null || cartItem.quantity == 0) {
                            return GestureDetector(
                              onTap: () {}, // Swallow taps to prevent navigation
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: const Size(60, 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  context.read<CartBloc>().add(AddItemToCart(productId: product.id, quantity: 1));
                                },
                                child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }

                          final item = cartItem;
                          return GestureDetector(
                            onTap: () {}, // Swallow taps to prevent navigation
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary.withAlpha(80)),
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.background,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.remove, size: 16, color: AppColors.primary),
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                        UpdateItemQuantity(lineId: item.id, quantity: item.quantity - 1),
                                      );
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                        UpdateItemQuantity(lineId: item.id, quantity: item.quantity + 1),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
