import 'package:flutter/material.dart';

class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({super.key, required this.rating, this.size = 16});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded, size: size, color: Colors.amber);
        } else if (i < rating) {
          return Icon(Icons.star_half_rounded, size: size, color: Colors.amber);
        } else {
          return Icon(Icons.star_outline_rounded,
              size: size, color: Colors.amber.withOpacity(0.4));
        }
      }),
    );
  }
}

class StarRatingInput extends StatelessWidget {
  const StarRatingInput({super.key, required this.rating, required this.onChanged});
  final double rating;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starVal = (i + 1).toDouble();
        return GestureDetector(
          onTap: () => onChanged(starVal),
          child: Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 36,
            color: i < rating ? Colors.amber : Colors.amber.withOpacity(0.4),
          ),
        );
      }),
    );
  }
}
