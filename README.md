# Meals App

A Flutter-based recipe browsing app that lets users explore meals by category, view full recipe details, and save their favourites.

---

## Tech Stack

| Layer    | Technology                        |
|----------|-----------------------------------|
| Frontend | Flutter 3, Material 3, Dart       |
| Fonts    | Google Fonts (Lato)               |
| Data     | Local dummy data (no backend)     |

---

## Features

### Browsing
- Browse meals organised in a colour-coded category grid
- Tap a category to see all meals within it
- View full recipe details — image, ingredients list, and step-by-step instructions

### Favourites
- Star any meal from its detail screen to save it
- Access all starred meals instantly from the Favourites tab
- Unstar a meal to remove it from favourites

---

## Project Structure

```
lib/
├── main.dart                    # App entry point and theme config
├── models/
│   ├── meal.dart                # Meal model (Complexity, Affordability enums)
│   └── category.dart            # Category model
├── screens/
│   ├── tabs.dart                # Root screen with bottom navigation
│   ├── categories.dart          # Category grid screen
│   ├── meals.dart               # Meals list screen
│   └── meal_details.dart        # Recipe detail screen
├── widgets/
│   ├── category_grid_item.dart  # Grid tile for a category
│   └── meal_item.dart           # List tile for a meal
└── data/
    └── dummy_data.dart          # Sample categories and meals
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.x or later
- Dart SDK (bundled with Flutter)
- Android Studio / Xcode for an emulator, or a physical device

---

### 1. Create a new Flutter project

```bash
flutter create meals_app
cd meals_app
```

---

### 2. Replace the lib/ folder

Delete the generated `lib/` folder and replace it with the one from this repository:

```
lib/
├── main.dart
├── models/
│   ├── meal.dart
│   └── category.dart
├── screens/
│   ├── tabs.dart
│   ├── categories.dart
│   ├── meals.dart
│   └── meal_details.dart
├── widgets/
│   ├── category_grid_item.dart
│   └── meal_item.dart
└── data/
    └── dummy_data.dart
```

---

### 3. Add dependencies

Open `pubspec.yaml` and add under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.0.0
```

---

### 4. Install and run

```bash
flutter pub get
flutter run
```

The app will launch on your connected device or emulator.

---

## App Structure

```
users
  ↓
CategoriesScreen      — grid of all available categories
  ↓
MealsScreen           — list of meals filtered by category
  ↓
MealDetailsScreen     — full recipe with image, ingredients, steps
  ↓
TabsScreen (root)     — manages bottom nav + favourites state
```

---

## Notes

- State is managed with plain `StatefulWidget` — no third-party state management
- The `TabsScreen` owns the favourites list and passes `_toggleMealFavoritesStatus` down via constructor arguments
- Navigation uses `Navigator.push` with `MaterialPageRoute`
- All meal data is hardcoded in `dummy_data.dart` — no network calls or backend required
- The star icon on the detail screen toggles the meal in and out of favourites in real time
