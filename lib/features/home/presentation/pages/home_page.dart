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
import 'package:delievry_app/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc _homeBloc;
  final ScrollController _scrollController = ScrollController();
  
  HomeLoaded? _preCachedState;
  bool _isPreCaching = false;

  @override
  void initState() {
    super.initState();
    _homeBloc = sl<HomeBloc>();
    if (_homeBloc.state is! HomeLoaded) {
      _homeBloc.add(FetchHomeData());
    } else {
      _preCachedState = _homeBloc.state as HomeLoaded;
    }
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

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.0.2.2:8000/storage/$url';
  }

  Future<void> _preCacheAllImages(HomeLoaded state) async {
    if (!mounted) return;
    setState(() {
      _isPreCaching = true;
    });

    final List<Future<void>> cacheFutures = [];
    final List<String> imageUrls = [];

    for (var banner in state.banners) {
      if (banner.imageUrl.isNotEmpty) {
        imageUrls.add(banner.imageUrl);
      }
    }
    for (var restaurant in state.restaurants) {
      if (restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty) {
        imageUrls.add(_resolveImageUrl(restaurant.imageUrl));
      }
    }

    for (var url in imageUrls) {
      final imageProvider = NetworkImage(url);
      cacheFutures.add(
        precacheImage(imageProvider, context).catchError((error) {
          debugPrint('Failed to precache image: $url. Error: $error');
        }),
      );
    }

    if (cacheFutures.isNotEmpty) {
      await Future.wait(cacheFutures).timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {
          debugPrint('Pre-caching images timed out, showing Home content anyway to avoid long loading screen.');
          return [];
        },
      );
    }

    if (mounted) {
      setState(() {
        _preCachedState = state;
        _isPreCaching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.deliverTo ?? 'Deliver to',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  Text(
                    'San Francisco, CA',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
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
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurface),
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
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeLoading) {
                _preCachedState = null;
              } else if (state is HomeLoaded && state != _preCachedState && !_isPreCaching) {
                _preCacheAllImages(state);
              }
            },
            builder: (context, state) {
              final isLoading = state is HomeLoading || (state is HomeLoaded && _preCachedState == null);
              
              return Stack(
                children: [
                  if (isLoading)
                    const HomeSkeleton()
                  else if (state is HomeLoaded)
                    SingleChildScrollView(
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
                    )
                  else if (state is HomeError)
                    Center(
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
                    )
                  else
                    const SizedBox.shrink(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
