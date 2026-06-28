import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../../di/injection_container.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_popular_meals.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late HomeBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = sl<HomeBloc>()..add(FetchHomeData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.search ?? 'Search'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (query) {
                  _searchBloc.add(SearchRequested(query));
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.searchForMeals ?? 'Search for meals...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _searchBloc.add(const SearchRequested(''));
                    },
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const ListSkeleton(itemCount: 4, height: 90);
                  } else if (state is HomeLoaded) {
                    final meals = state.popularMeals;

                    if (meals.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)?.mealNotFound ?? 'The meal you are searching for does not exist.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return ListView(
                      children: [
                        HomePopularMeals(meals: meals),
                      ],
                    );
                  } else if (state is HomeError) {
                    return Center(child: Text(state.message));
                  }
                  return Center(
                    child: Text(AppLocalizations.of(context)?.searchFavoriteFood ?? 'Search for your favorite food!'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
