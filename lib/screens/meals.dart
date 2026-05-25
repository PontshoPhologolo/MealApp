import 'package:flutter/material.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/models/meal_filters.dart';
import 'package:meals/screens/meal_details.dart';
import 'package:meals/services/meal_service.dart';
import 'package:meals/widgets/meal_item.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({
    super.key,
    required this.title,
    required this.filters,
    this.categoryId,
    this.meals,
  });

  final String title;
  final MealFilters filters;
  final String? categoryId;
  final List<Meal>? meals; // optional pre-filtered list (favourites)

  List<Meal> _applyFilters(List<Meal> all) {
    return all.where((m) {
      if (categoryId != null && !m.categories.contains(categoryId)) return false;
      if (filters.glutenFree && !m.isGlutenFree) return false;
      if (filters.lactoseFree && !m.isLactoseFree) return false;
      if (filters.vegan && !m.isVegan) return false;
      if (filters.vegetarian && !m.isVegetarian) return false;
      return true;
    }).toList();
  }

  void _selectMeal(BuildContext context, Meal meal) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (ctx, animation, _) => MealDetailsScreen(meal: meal),
      transitionsBuilder: (ctx, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (meals != null) {
      // Pre-supplied list (favourites screen)
      final filtered = _applyFilters(meals!);
      return _buildList(context, filtered);
    }

    return StreamBuilder<List<Meal>>(
      stream: MealService().mealsStream(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final filtered = _applyFilters(snapshot.data ?? []);
        return _buildList(ctx, filtered);
      },
    );
  }

  Widget _buildList(BuildContext context, List<Meal> filtered) {
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_meals, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('Nothing here!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    )),
            const SizedBox(height: 8),
            Text('Try adjusting your filters',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => MealItem(
          meal: filtered[i],
          onSelectMeal: (ctx, meal) => _selectMeal(ctx, meal),
        ),
      ),
    );
  }
}
