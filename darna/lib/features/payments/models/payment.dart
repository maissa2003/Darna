class PaymentMethod {
  static const card = 'card';
  static const wallet = 'wallet';
  static const cash = 'cash';

  static String label(String method) => switch (method) {
        card => 'Carte bancaire',
        wallet => 'Portefeuille mobile',
        cash => 'Espèces à la remise des clés',
        _ => method,
      };
}

class PaymentStatus {
  static const paid = 'paid';
  static const cashPending = 'cash_pending'; // student will pay on move-in

  static String label(String status) => switch (status) {
        paid => 'Payé',
        cashPending => 'Paiement en espèces prévu',
        _ => status,
      };
}

/// A payment for an accepted reservation. Only the last digits of a card
/// are kept, never the full number or the CVV.
class Payment {
  final String id;
  final String bookingId;
  final String propertyId;
  final String studentId;
  final String ownerId;
  final int amount; // TND
  final String method;
  final String status;
  final String reference;
  final String? detail; // e.g. card last 4 digits or wallet phone
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.propertyId,
    required this.studentId,
    required this.ownerId,
    required this.amount,
    required this.method,
    required this.status,
    required this.reference,
    this.detail,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookingId': bookingId,
        'propertyId': propertyId,
        'studentId': studentId,
        'ownerId': ownerId,
        'amount': amount,
        'method': method,
        'status': status,
        'reference': reference,
        'detail': detail,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Payment.fromMap(Map map) => Payment(
        id: map['id'] as String,
        bookingId: map['bookingId'] as String,
        propertyId: map['propertyId'] as String,
        studentId: map['studentId'] as String,
        ownerId: map['ownerId'] as String,
        amount: map['amount'] as int,
        method: map['method'] as String,
        status: map['status'] as String,
        reference: map['reference'] as String,
        detail: map['detail'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}
