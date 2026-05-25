import 'package:flutter/material.dart';
import 'package:meals/models/meal_filters.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  final MealFilters currentFilters;
  final void Function(MealFilters) onApply;

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late MealFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF180C04),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Dietary Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Only show meals that match all selected filters',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 20),
          _FilterTile(
            icon: Icons.no_food_rounded,
            label: 'Gluten-Free',
            subtitle: 'Hide meals containing gluten',
            value: _filters.glutenFree,
            onChanged: (v) => setState(() => _filters = _filters.copyWith(glutenFree: v)),
          ),
          _FilterTile(
            icon: Icons.local_drink_outlined,
            label: 'Lactose-Free',
            subtitle: 'Hide meals containing dairy',
            value: _filters.lactoseFree,
            onChanged: (v) => setState(() => _filters = _filters.copyWith(lactoseFree: v)),
          ),
          _FilterTile(
            icon: Icons.eco_rounded,
            label: 'Vegan',
            subtitle: 'No animal products whatsoever',
            value: _filters.vegan,
            onChanged: (v) => setState(() => _filters = _filters.copyWith(vegan: v)),
          ),
          _FilterTile(
            icon: Icons.grass_rounded,
            label: 'Vegetarian',
            subtitle: 'No meat or fish',
            value: _filters.vegetarian,
            onChanged: (v) => setState(() => _filters = _filters.copyWith(vegetarian: v)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _filters = const MealFilters());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onSurface.withOpacity(0.6),
                    side: BorderSide(color: scheme.onSurface.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_filters);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? scheme.primary.withOpacity(0.08) : const Color(0xFF241509),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? scheme.primary.withOpacity(0.35) : Colors.transparent,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon,
            color: value ? scheme.primary : scheme.onSurface.withOpacity(0.45)),
        title: Text(label,
            style: TextStyle(
                fontWeight: value ? FontWeight.bold : FontWeight.normal,
                color: value ? scheme.primary : scheme.onSurface)),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 12, color: scheme.onSurface.withOpacity(0.4))),
        activeColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
