enum Complexity { simple, challenging, hard }
enum Affordability { affordable, pricey, luxurious }

class Meal {
  const Meal({
    required this.id,
    required this.categories,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.complexity,
    required this.affordability,
    required this.isGlutenFree,
    required this.isLactoseFree,
    required this.isVegan,
    required this.isVegetarian,
    this.averageRating = 0.0,
    this.reviewCount = 0,
  });

  final String id;
  final List<String> categories;
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final int duration;
  final Complexity complexity;
  final Affordability affordability;
  final bool isGlutenFree;
  final bool isLactoseFree;
  final bool isVegan;
  final bool isVegetarian;
  final double averageRating;
  final int reviewCount;

  factory Meal.fromFirestore(Map<String, dynamic> data, String id) {
    return Meal(
      id: id,
      categories: List<String>.from(data['categories'] ?? []),
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      duration: data['duration'] ?? 0,
      complexity: Complexity.values.firstWhere(
        (e) => e.name == data['complexity'],
        orElse: () => Complexity.simple,
      ),
      affordability: Affordability.values.firstWhere(
        (e) => e.name == data['affordability'],
        orElse: () => Affordability.affordable,
      ),
      isGlutenFree: data['isGlutenFree'] ?? false,
      isLactoseFree: data['isLactoseFree'] ?? false,
      isVegan: data['isVegan'] ?? false,
      isVegetarian: data['isVegetarian'] ?? false,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categories': categories,
      'title': title,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'steps': steps,
      'duration': duration,
      'complexity': complexity.name,
      'affordability': affordability.name,
      'isGlutenFree': isGlutenFree,
      'isLactoseFree': isLactoseFree,
      'isVegan': isVegan,
      'isVegetarian': isVegetarian,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }

  String get complexityLabel {
    switch (complexity) {
      case Complexity.simple: return 'Simple';
      case Complexity.challenging: return 'Challenging';
      case Complexity.hard: return 'Hard';
    }
  }

  String get affordabilityLabel {
    switch (affordability) {
      case Affordability.affordable: return 'Affordable';
      case Affordability.pricey: return 'Pricey';
      case Affordability.luxurious: return 'Luxurious';
    }
  }
}
