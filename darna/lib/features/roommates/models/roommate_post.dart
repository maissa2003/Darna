class RoommatePost {
  final String id;
  final String userId;
  final String kind; // 'offer' = has a place, 'request' = looking for one
  final String title;
  final String city;
  final String university;
  final int budget; // TND / month
  final String gender; // gender of the author: 'female' | 'male'
  final String description;
  final List<String> lifestyle;
  final DateTime createdAt;

  RoommatePost({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.city,
    required this.university,
    required this.budget,
    required this.gender,
    required this.description,
    required this.lifestyle,
    required this.createdAt,
  });

  bool get isOffer => kind == 'offer';

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'kind': kind,
        'title': title,
        'city': city,
        'university': university,
        'budget': budget,
        'gender': gender,
        'description': description,
        'lifestyle': lifestyle,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory RoommatePost.fromMap(Map map) => RoommatePost(
        id: map['id'] as String,
        userId: map['userId'] as String,
        kind: map['kind'] as String,
        title: map['title'] as String,
        city: map['city'] as String,
        university: map['university'] as String? ?? '',
        budget: map['budget'] as int,
        gender: map['gender'] as String,
        description: map['description'] as String? ?? '',
        lifestyle: List<String>.from(map['lifestyle'] as List? ?? const []),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}

class RoommateContact {
  final String id;
  final String postId;
  final String fromUserId;
  final String toUserId;
  final String message;
  String status; // pending | accepted | rejected
  final DateTime createdAt;

  RoommateContact({
    required this.id,
    required this.postId,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'postId': postId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'message': message,
        'status': status,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory RoommateContact.fromMap(Map map) => RoommateContact(
        id: map['id'] as String,
        postId: map['postId'] as String,
        fromUserId: map['fromUserId'] as String,
        toUserId: map['toUserId'] as String,
        message: map['message'] as String? ?? '',
        status: map['status'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}
