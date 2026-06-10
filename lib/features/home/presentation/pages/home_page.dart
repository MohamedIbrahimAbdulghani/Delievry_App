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
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.onBackground),
                onPressed: () => context.push('/notifications'),
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
