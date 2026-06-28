import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../../di/injection_container.dart';
import '../bloc/restaurant_detail_bloc.dart';
import '../bloc/restaurant_detail_event.dart';
import '../bloc/restaurant_detail_state.dart';
import '../widgets/restaurant_info_header.dart';
import '../widgets/restaurant_menu_tabs.dart';
import '../widgets/restaurant_reviews.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<RestaurantDetailBloc, RestaurantDetailState>(
          builder: (context, state) {
            if (state is RestaurantDetailLoading) {
              return const RestaurantDetailsSkeleton();
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
                        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
                        onPressed: () => context.pop(),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            state.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: state.isFavorite ? AppColors.primary : Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: () => _bloc.add(ToggleFavorite(widget.restaurantId)),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          restaurant.imageUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          tabs: [
                            Tab(text: AppLocalizations.of(context)?.menuTab ?? 'Menu'),
                            Tab(text: AppLocalizations.of(context)?.reviewsTab ?? 'Reviews'),
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
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(AppLocalizations.of(context)?.restaurantDetails ?? 'Restaurant Details', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.store_outlined, size: 80, color: AppColors.primary),
                        const SizedBox(height: 24),
                        Text(
                          'Restaurant Unavailable',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message.contains('Forbidden') || state.message.contains('403')
                              ? 'This restaurant is temporarily inactive or not accepting orders.'
                              : state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
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
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
