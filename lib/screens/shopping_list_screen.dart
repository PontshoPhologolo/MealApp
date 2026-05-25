import 'package:flutter/material.dart';
import 'package:meals/services/meal_service.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final service = MealService();
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<Map<String, bool>>(
      stream: service.shoppingListStream(userId),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? {};

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 72, color: scheme.primary.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('Your shopping list is empty',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: scheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 8),
                Text('Add ingredients from any meal\'s detail page',
                    style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
              ],
            ),
          );
        }

        final unchecked = items.entries.where((e) => !e.value).toList();
        final checked = items.entries.where((e) => e.value).toList();

        return Column(
          children: [
            if (checked.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => service.clearCheckedItems(userId),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                      label: const Text('Clear checked'),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (unchecked.isNotEmpty) ...[
                    _SectionLabel(
                        label: 'To get (${unchecked.length})', scheme: scheme),
                    ...unchecked.map((e) => _ShoppingItem(
                          itemId: e.key,
                          items: items,
                          userId: userId,
                          service: service,
                        )),
                  ],
                  if (checked.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _SectionLabel(
                        label: 'Done (${checked.length})', scheme: scheme, muted: true),
                    ...checked.map((e) => _ShoppingItem(
                          itemId: e.key,
                          items: items,
                          userId: userId,
                          service: service,
                        )),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.scheme, this.muted = false});
  final String label;
  final ColorScheme scheme;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: muted
              ? scheme.onSurface.withOpacity(0.35)
              : scheme.primary.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ShoppingItem extends StatelessWidget {
  const _ShoppingItem({
    required this.itemId,
    required this.items,
    required this.userId,
    required this.service,
  });

  final String itemId;
  final Map<String, bool> items;
  final String userId;
  final MealService service;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final checked = items[itemId] ?? false;

    // Reconstruct display name from the key
    final displayName = itemId.replaceAll('_', ' ');

    return Dismissible(
      key: Key(itemId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      onDismissed: (_) => service.removeShoppingItem(userId, itemId),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: checked
              ? const Color(0xFF1A1008)
              : const Color(0xFF241509),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: checked
                ? Colors.transparent
                : scheme.primary.withOpacity(0.15),
          ),
        ),
        child: CheckboxListTile(
          value: checked,
          onChanged: (val) =>
              service.toggleShoppingItem(userId, itemId, val ?? false),
          title: Text(
            displayName,
            style: TextStyle(
              decoration: checked ? TextDecoration.lineThrough : null,
              color: checked
                  ? scheme.onSurface.withOpacity(0.35)
                  : scheme.onSurface.withOpacity(0.85),
            ),
          ),
          activeColor: scheme.primary,
          checkColor: Colors.white,
          controlAffinity: ListTileControlAffinity.leading,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
