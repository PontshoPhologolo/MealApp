import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meals/models/meal_filters.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/favourites_screen.dart';
import 'package:meals/screens/shopping_list_screen.dart';
import 'package:meals/screens/search_screen.dart';
import 'package:meals/services/auth_service.dart';
import 'package:meals/services/meal_service.dart';
import 'package:meals/widgets/filter_drawer.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;
  MealFilters _filters = const MealFilters();
  final _mealService = MealService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _mealService.seedMealsIfEmpty();
  }

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Categories'),
    _NavItem(icon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Favourites'),
    _NavItem(icon: Icons.shopping_cart_rounded, label: 'Shopping'),
  ];

  Widget _buildPage() {
    final user = FirebaseAuth.instance.currentUser!;
    switch (_selectedIndex) {
      case 0:
        return CategoriesScreen(filters: _filters);
      case 1:
        return SearchScreen(filters: _filters);
      case 2:
        return FavouritesScreen(userId: user.uid, filters: _filters);
      case 3:
        return ShoppingListScreen(userId: user.uid);
      default:
        return CategoriesScreen(filters: _filters);
    }
  }

  String get _title {
    switch (_selectedIndex) {
      case 0: return 'Discover';
      case 1: return 'Search';
      case 2: return 'Favourites';
      case 3: return 'Shopping List';
      default: return 'MealsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          if (_selectedIndex == 0)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => FilterDrawer(
                        currentFilters: _filters,
                        onApply: (f) => setState(() => _filters = f),
                      ),
                    );
                  },
                ),
                if (_filters.hasActiveFilters)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async => await _authService.signOut(),
          ),
        ],
      ),
      extendBodyBehindAppBar: false,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_selectedIndex), child: _buildPage()),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF180C04),
          border: Border(top: BorderSide(color: scheme.primary.withOpacity(0.2))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isSelected = _selectedIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? scheme.primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? scheme.primary : scheme.onSurface.withOpacity(0.4),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? scheme.primary : scheme.onSurface.withOpacity(0.4),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
