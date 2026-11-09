import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/box_names.dart';
import '../../bookings/models/booking.dart';
import '../models/payment.dart';

/// Demo payments: nothing is charged. To accept real payments, replace
/// [pay] with a call to a Tunisian gateway (Konnect, Flouci, Paymee…)
/// made from a backend, and store the gateway's reference here.
class PaymentRepository {
  Box get _box => Hive.box(BoxNames.payments);

  ValueListenable<Box> listenable() => _box.listenable();

  /// Payments are keyed by booking: one payment per reservation.
  Payment? forBooking(String bookingId) {
    final map = _box.get(bookingId);
    return map == null ? null : Payment.fromMap(map as Map);
  }

  Future<Payment> pay({
    required Booking booking,
    required int amount,
    required String method,
    String? detail,
  }) async {
    // Simulates the round-trip to a payment provider.
    await Future.delayed(const Duration(milliseconds: 1800));
    final payment = Payment(
      id: const Uuid().v4(),
      bookingId: booking.id,
      propertyId: booking.propertyId,
      studentId: booking.studentId,
      ownerId: booking.ownerId,
      amount: amount,
      method: method,
      status: method == PaymentMethod.cash
          ? PaymentStatus.cashPending
          : PaymentStatus.paid,
      reference: _newReference(),
      detail: detail,
      createdAt: DateTime.now(),
    );
    await _box.put(booking.id, payment.toMap());
    return payment;
  }

  /// Owner confirms they received the cash on move-in.
  Future<void> confirmCash(Payment payment) {
    final updated = Payment.fromMap(payment.toMap()..['status'] = PaymentStatus.paid);
    return _box.put(payment.bookingId, updated.toMap());
  }

  String _newReference() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return 'DRN-${List.generate(8, (_) => chars[r.nextInt(chars.length)]).join()}';
  }
}
