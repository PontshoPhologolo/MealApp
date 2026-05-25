import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/models/review.dart';
import 'package:meals/services/meal_service.dart';
import 'package:meals/widgets/star_rating.dart';
import 'package:meals/widgets/review_card.dart';

class MealDetailsScreen extends StatefulWidget {
  const MealDetailsScreen({super.key, required this.meal});
  final Meal meal;

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  final _mealService = MealService();
  late Meal _meal;

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
  }

  String get _userId => FirebaseAuth.instance.currentUser!.uid;
  String get _userEmail => FirebaseAuth.instance.currentUser!.email ?? 'Anonymous';

  Future<void> _addToShoppingList() async {
    await _mealService.addIngredientsToShoppingList(_userId, _meal.ingredients);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_meal.ingredients.length} ingredients added to shopping list'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showReviewDialog() async {
    final hasReviewed = await _mealService.hasUserReviewed(_userId, _meal.id);
    if (hasReviewed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already reviewed this meal')),
      );
      return;
    }
    if (!mounted) return;

    double rating = 3;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A0D05),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leave a Review',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Center(
                  child: StarRatingInput(
                    rating: rating,
                    onChanged: (r) => setModalState(() => rating = r),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Your thoughts...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final review = Review(
                        id: '',
                        mealId: _meal.id,
                        userId: _userId,
                        userEmail: _userEmail,
                        rating: rating,
                        comment: commentController.text.trim(),
                        createdAt: DateTime.now(),
                      );
                      await _mealService.submitReview(review);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Submit Review'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final userId = _userId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0D0602),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _meal.title,
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(blurRadius: 8, color: Colors.black)],
                ),
              ),
              background: Hero(
                tag: 'meal-${_meal.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(_meal.imageUrl, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Favourite toggle
              StreamBuilder<List<String>>(
                stream: _mealService.favouritesStream(userId),
                builder: (ctx, snapshot) {
                  final favs = snapshot.data ?? [];
                  final isFav = favs.contains(_meal.id);
                  return IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFav),
                        color: isFav ? Colors.redAccent : Colors.white,
                      ),
                    ),
                    onPressed: () => _mealService.toggleFavourite(userId, _meal.id, isFav),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(icon: Icons.timer, label: '${_meal.duration} min'),
                      _MetaChip(icon: Icons.bar_chart, label: _meal.complexityLabel),
                      _MetaChip(icon: Icons.attach_money, label: _meal.affordabilityLabel),
                      if (_meal.isGlutenFree) _MetaChip(icon: Icons.check_circle, label: 'Gluten-Free', highlight: true),
                      if (_meal.isLactoseFree) _MetaChip(icon: Icons.check_circle, label: 'Lactose-Free', highlight: true),
                      if (_meal.isVegan) _MetaChip(icon: Icons.eco, label: 'Vegan', highlight: true),
                      if (_meal.isVegetarian) _MetaChip(icon: Icons.grass, label: 'Vegetarian', highlight: true),
                    ],
                  ),

                  // Rating summary
                  if (_meal.reviewCount > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        StarRatingDisplay(rating: _meal.averageRating),
                        const SizedBox(width: 8),
                        Text(
                          '${_meal.averageRating.toStringAsFixed(1)} (${_meal.reviewCount} reviews)',
                          style: TextStyle(color: scheme.onSurface.withOpacity(0.6), fontSize: 13),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Add to shopping list button
                  OutlinedButton.icon(
                    onPressed: _addToShoppingList,
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text('Add ingredients to shopping list'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.primary,
                      side: BorderSide(color: scheme.primary.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 28),
                  _SectionHeader(title: 'Ingredients', icon: Icons.kitchen_rounded),
                  const SizedBox(height: 12),
                  ...List.generate(_meal.ingredients.length, (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _meal.ingredients[i],
                            style: TextStyle(color: scheme.onSurface.withOpacity(0.85)),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 28),
                  _SectionHeader(title: 'Steps', icon: Icons.format_list_numbered_rounded),
                  const SizedBox(height: 12),
                  ...List.generate(_meal.steps.length, (i) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF241509),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.primary.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _meal.steps[i],
                            style: TextStyle(color: scheme.onSurface.withOpacity(0.85), height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionHeader(title: 'Reviews', icon: Icons.rate_review_rounded),
                      TextButton.icon(
                        onPressed: _showReviewDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Write a review'),
                        style: TextButton.styleFrom(foregroundColor: scheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Reviews stream
          StreamBuilder<List<Review>>(
            stream: _mealService.reviewsStream(_meal.id),
            builder: (ctx, snapshot) {
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'No reviews yet — be the first!',
                      style: TextStyle(color: scheme.onSurface.withOpacity(0.4)),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => ReviewCard(review: reviews[i]),
                    childCount: reviews.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, this.highlight = false});
  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? scheme.primary.withOpacity(0.15) : const Color(0xFF2C1A0A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight ? scheme.primary.withOpacity(0.4) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: highlight ? scheme.primary : scheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: highlight ? scheme.primary : scheme.onSurface.withOpacity(0.6),
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
