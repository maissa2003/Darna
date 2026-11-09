class BookingStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
  static const cancelled = 'cancelled';

  static String label(String status) => switch (status) {
        pending => 'En attente',
        accepted => 'Acceptée',
        rejected => 'Refusée',
        cancelled => 'Annulée',
        _ => status,
      };
}

class Booking {
  final String id;
  final String propertyId;
  final String studentId;
  final String ownerId;
  final String kind; // 'visit' | 'reservation'
  final DateTime date;
  final String message;
  String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.propertyId,
    required this.studentId,
    required this.ownerId,
    required this.kind,
    required this.date,
    required this.message,
    this.status = BookingStatus.pending,
    required this.createdAt,
  });

  String get kindLabel => kind == 'visit' ? 'Visite' : 'Réservation';

  Map<String, dynamic> toMap() => {
        'id': id,
        'propertyId': propertyId,
        'studentId': studentId,
        'ownerId': ownerId,
        'kind': kind,
        'date': date.millisecondsSinceEpoch,
        'message': message,
        'status': status,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Booking.fromMap(Map map) => Booking(
        id: map['id'] as String,
        propertyId: map['propertyId'] as String,
        studentId: map['studentId'] as String,
        ownerId: map['ownerId'] as String,
        kind: map['kind'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
        message: map['message'] as String? ?? '',
        status: map['status'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}
