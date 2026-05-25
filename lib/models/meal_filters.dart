class MealFilters {
  const MealFilters({
    this.glutenFree = false,
    this.lactoseFree = false,
    this.vegan = false,
    this.vegetarian = false,
  });

  final bool glutenFree;
  final bool lactoseFree;
  final bool vegan;
  final bool vegetarian;

  MealFilters copyWith({
    bool? glutenFree,
    bool? lactoseFree,
    bool? vegan,
    bool? vegetarian,
  }) {
    return MealFilters(
      glutenFree: glutenFree ?? this.glutenFree,
      lactoseFree: lactoseFree ?? this.lactoseFree,
      vegan: vegan ?? this.vegan,
      vegetarian: vegetarian ?? this.vegetarian,
    );
  }

  bool get hasActiveFilters => glutenFree || lactoseFree || vegan || vegetarian;
}
