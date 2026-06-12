import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection_container.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_banners.dart';
import '../widgets/home_categories.dart';
import '../widgets/home_restaurants.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_skeleton.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc _homeBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _homeBloc = sl<HomeBloc>()..add(FetchHomeData());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _homeBloc.add(FetchMoreRestaurants());
      _homeBloc.add(FetchMoreMeals());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _homeBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deliver to',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  Text(
                    'San Francisco, CA',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
          actions: [
            BlocProvider(
              create: (context) => sl<NotificationsBloc>()..add(FetchNotifications()),
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  int unreadCount = 0;
                  if (state is NotificationsLoaded) {
                    unreadCount = state.notifications.where((n) => !n.isRead).length;
                  }
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none, color: AppColors.onBackground),
                          onPressed: () async {
                            await context.push('/notifications');
                            if (context.mounted) {
                              context.read<NotificationsBloc>().add(FetchNotifications());
                            }
                          },
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 12,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _homeBloc.add(RefreshHomeData());
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const HomeSkeleton();
              } else if (state is HomeLoaded) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HomeSearchBar(),
                      HomeBanners(banners: state.banners),
                      HomeCategories(
                        categories: state.categories,
                        selectedCategoryId: state.selectedCategoryId,
                      ),
                      HomeRestaurants(restaurants: state.restaurants),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              } else if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _homeBloc.add(FetchHomeData()),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
