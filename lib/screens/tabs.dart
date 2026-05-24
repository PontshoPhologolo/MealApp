import 'package:flutter/material.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/meals.dart';

class TabsScreen extends StatefulWidget
{
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
   return _TabsScreenState();
  }

}

class _TabsScreenState extends State<TabsScreen> 
{
    int _selectedPageIndex = 0 ;
    final List<Meal> _favouritesMeals = [];

  void _toggleMealFavoritesStatus( Meal meal)
  {
    final isExisting = _favouritesMeals.contains(meal); 

    if(isExisting)
    {
      _favouritesMeals.remove(meal);
    }
    else 
    {
      _favouritesMeals.add(meal);
    }
  }
    void _selectPage(int index)
    {
      setState(() {
        _selectedPageIndex = index;
      });
    }

  @override
  Widget build(BuildContext context) {

    Widget activePage =  CategoriesScreen(onToggleFavorite: _toggleMealFavoritesStatus);
    var activePageTitle = 'Categories';

    if (_selectedPageIndex == 1) {
      activePage = MealsScreen(
    meals: _favouritesMeals,  // Use the actual favorites list
    onToggleFavorite: _toggleMealFavoritesStatus,
  );
  activePageTitle = 'Your Favourites';
}
    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.set_meal, ), label: 'Category'),
           BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favourites'),
        ]),
    );
  }
  
}