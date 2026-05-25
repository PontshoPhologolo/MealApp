class Review {
  const Review({
    required this.id,
    required this.mealId,
    required this.userId,
    required this.userEmail,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String mealId;
  final String userId;
  final String userEmail;
  final double rating;
  final String comment;
  final DateTime createdAt;

  factory Review.fromFirestore(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      mealId: data['mealId'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mealId': mealId,
      'userId': userId,
      'userEmail': userEmail,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
