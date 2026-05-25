import 'package:flutter/material.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/models/meal_filters.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/services/meal_service.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key, required this.userId, required this.filters});

  final String userId;
  final MealFilters filters;

  @override
  Widget build(BuildContext context) {
    final service = MealService();

    return StreamBuilder<List<String>>(
      stream: service.favouritesStream(userId),
      builder: (ctx, favSnapshot) {
        if (favSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final favIds = favSnapshot.data ?? [];

        return StreamBuilder<List<Meal>>(
          stream: service.mealsStream(),
          builder: (ctx, mealSnapshot) {
            if (mealSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final favMeals = (mealSnapshot.data ?? [])
                .where((m) => favIds.contains(m.id))
                .toList();

            if (favMeals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('No favourites yet',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 8),
                    Text('Tap the heart on any meal to save it here',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                  ],
                ),
              );
            }

            return MealsScreen(
              title: 'Your Favourites',
              filters: filters,
              meals: favMeals,
            );
          },
        );
      },
    );
  }
}
