import 'package:flutter/material.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/models/meal_filters.dart';
import 'package:meals/screens/meal_details.dart';
import 'package:meals/services/meal_service.dart';
import 'package:meals/widgets/meal_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.filters});
  final MealFilters filters;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Meal> _filter(List<Meal> all) {
    return all.where((m) {
      final matchesQuery = _query.isEmpty ||
          m.title.toLowerCase().contains(_query.toLowerCase()) ||
          m.ingredients.any((i) => i.toLowerCase().contains(_query.toLowerCase()));
      if (!matchesQuery) return false;
      if (widget.filters.glutenFree && !m.isGlutenFree) return false;
      if (widget.filters.lactoseFree && !m.isLactoseFree) return false;
      if (widget.filters.vegan && !m.isVegan) return false;
      if (widget.filters.vegetarian && !m.isVegetarian) return false;
      return true;
    }).toList();
  }

  void _selectMeal(BuildContext context, Meal meal) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MealDetailsScreen(meal: meal),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            controller: _controller,
            autofocus: false,
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search meals or ingredients...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Meal>>(
            stream: MealService().mealsStream(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final results = _filter(snapshot.data ?? []);

              if (_query.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 64,
                          color: scheme.primary.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('Search by meal name or ingredient',
                          style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
                    ],
                  ),
                );
              }

              if (results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.no_meals, size: 64,
                          color: scheme.primary.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No results for "$_query"',
                          style: TextStyle(color: scheme.onSurface.withOpacity(0.5))),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: results.length,
                itemBuilder: (ctx, i) => MealItem(
                  meal: results[i],
                  onSelectMeal: (ctx, meal) => _selectMeal(ctx, meal),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
