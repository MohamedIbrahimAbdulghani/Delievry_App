import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';

class HomeCategories extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String selectedCategoryId;

  const HomeCategories({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            'Categories',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: 20,
            ) ?? const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
        SizedBox(
          height: 115,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.id == selectedCategoryId;
              
              return GestureDetector(
                onTap: () {
                  context.read<HomeBloc>().add(FilterByCategory(category.id));
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                  ? AppColors.primary.withAlpha(50) 
                                  : AppColors.primary.withAlpha(15),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(category.name),
                            color: isSelected ? Colors.white : AppColors.primary,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.onBackground,
                        ) ?? TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.onBackground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'pizza': return Icons.local_pizza_rounded;
      case 'burgers': return Icons.lunch_dining_rounded;
      case 'broast': return Icons.restaurant_menu_rounded;
      case 'pasta': return Icons.dinner_dining_rounded;
      case 'sides': return Icons.cookie_rounded;
      default: return Icons.fastfood_rounded;
    }
  }
}
