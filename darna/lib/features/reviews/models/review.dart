class Review {
  final String id;
  final String propertyId;
  final String userId;
  final String userName;
  final int rating; // 1..5
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'propertyId': propertyId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Review.fromMap(Map map) => Review(
        id: map['id'] as String,
        propertyId: map['propertyId'] as String,
        userId: map['userId'] as String,
        userName: map['userName'] as String,
        rating: map['rating'] as int,
        comment: map['comment'] as String? ?? '',
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}
