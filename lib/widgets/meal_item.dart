import 'package:flutter/material.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/widgets/star_rating.dart';

class MealItem extends StatelessWidget {
  const MealItem({super.key, required this.meal, required this.onSelectMeal});

  final Meal meal;
  final void Function(BuildContext context, Meal meal) onSelectMeal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => onSelectMeal(context, meal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with hero
            Stack(
              children: [
                Hero(
                  tag: 'meal-${meal.id}',
                  child: Image.network(
                    meal.imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                // Duration badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.duration} min',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                // Dietary badges
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: [
                      if (meal.isVegan)
                        _Badge(label: 'V', color: Colors.green.shade700),
                      if (meal.isVegetarian && !meal.isVegan)
                        _Badge(label: 'VG', color: Colors.lightGreen.shade700),
                      if (meal.isGlutenFree)
                        _Badge(label: 'GF', color: Colors.orange.shade800),
                      if (meal.isLactoseFree)
                        _Badge(label: 'LF', color: Colors.blue.shade700),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.bar_chart, size: 13,
                          color: scheme.onSurface.withOpacity(0.45)),
                      const SizedBox(width: 4),
                      Text(meal.complexityLabel,
                          style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurface.withOpacity(0.45))),
                      const SizedBox(width: 12),
                      Icon(Icons.attach_money, size: 13,
                          color: scheme.onSurface.withOpacity(0.45)),
                      Text(meal.affordabilityLabel,
                          style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurface.withOpacity(0.45))),
                      if (meal.reviewCount > 0) ...[
                        const Spacer(),
                        StarRatingDisplay(rating: meal.averageRating, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          meal.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
