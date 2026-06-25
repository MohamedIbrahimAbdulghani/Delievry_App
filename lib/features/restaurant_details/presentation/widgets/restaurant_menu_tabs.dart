import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/restaurant_detail_entity.dart';

class RestaurantMenuTabs extends StatefulWidget {
  final RestaurantDetailEntity restaurant;

  const RestaurantMenuTabs({super.key, required this.restaurant});

  @override
  State<RestaurantMenuTabs> createState() => _RestaurantMenuTabsState();
}

class _RestaurantMenuTabsState extends State<RestaurantMenuTabs> {
  CartEntity? _cachedCart;

  @override
  void initState() {
    super.initState();
    final cartState = context.read<CartBloc>().state;
    if (cartState is CartLoaded) {
      _cachedCart = cartState.cart;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.restaurant.products.isEmpty) {
      return const Center(child: Text('No items available in the menu.'));
    }

    final categories = widget.restaurant.categories;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        final products = widget.restaurant.products.where((p) => p.category == category).toList();

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
                          if (state is CartLoaded) {
                            _cachedCart = state.cart;
                          }

                          final isUpdating = state is CartLoading;

                          CartItemEntity? cartItem;
                          if (_cachedCart != null) {
                            for (var item in _cachedCart!.items) {
                              if (item.product.id == product.id) {
                                cartItem = item;
                                break;
                              }
                            }
                          }

                          if (cartItem == null || cartItem.quantity == 0) {
                            return GestureDetector(
                              onTap: () {}, // Swallow taps to prevent navigation
                              child: InkWell(
                                onTap: isUpdating
                                    ? null
                                    : () {
                                        context.read<CartBloc>().add(
                                          AddItemToCart(productId: product.id, quantity: 1),
                                        );
                                      },
                                borderRadius: BorderRadius.circular(18),
                                child: Opacity(
                                  opacity: isUpdating ? 0.6 : 1.0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withAlpha(50),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final item = cartItem;
                          return GestureDetector(
                            onTap: () {}, // Swallow taps to prevent navigation
                            child: Opacity(
                              opacity: isUpdating ? 0.6 : 1.0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: isUpdating
                                        ? null
                                        : () {
                                            context.read<CartBloc>().add(
                                              UpdateItemQuantity(lineId: item.id, quantity: item.quantity - 1),
                                            );
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: const Icon(Icons.remove, color: Colors.black54, size: 18),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onBackground,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: isUpdating
                                        ? null
                                        : () {
                                            context.read<CartBloc>().add(
                                              UpdateItemQuantity(lineId: item.id, quantity: item.quantity + 1),
                                            );
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.black54, size: 18),
                                    ),
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
