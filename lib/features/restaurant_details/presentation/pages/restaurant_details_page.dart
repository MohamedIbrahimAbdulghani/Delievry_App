import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection_container.dart';
import '../bloc/restaurant_detail_bloc.dart';
import '../bloc/restaurant_detail_event.dart';
import '../bloc/restaurant_detail_state.dart';
import '../widgets/restaurant_info_header.dart';
import '../widgets/restaurant_menu_tabs.dart';
import '../widgets/restaurant_reviews.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailsPage({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> with SingleTickerProviderStateMixin {
  late RestaurantDetailBloc _bloc;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _bloc = sl<RestaurantDetailBloc>()..add(FetchRestaurantDetails(widget.restaurantId));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RestaurantDetailBloc, RestaurantDetailState>(
          builder: (context, state) {
            if (state is RestaurantDetailLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is RestaurantDetailLoaded) {
              final restaurant = state.restaurant;
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250,
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            state.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: state.isFavorite ? AppColors.primary : Colors.white,
                          ),
                          onPressed: () => _bloc.add(ToggleFavorite(widget.restaurantId)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          restaurant.imageUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.restaurant, size: 100, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: RestaurantInfoHeader(restaurant: restaurant),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.primary,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          tabs: const [
                            Tab(text: 'Menu'),
                            Tab(text: 'Reviews'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    RestaurantMenuTabs(restaurant: restaurant),
                    RestaurantReviews(reviews: restaurant.reviews),
                  ],
                ),
              );
            } else if (state is RestaurantDetailError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
