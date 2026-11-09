import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/box_names.dart';
import '../models/booking.dart';

class BookingRepository {
  Box get _box => Hive.box(BoxNames.bookings);

  ValueListenable<Box> listenable() => _box.listenable();

  List<Booking> _all() {
    final list = _box.values.map((m) => Booking.fromMap(m as Map)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Booking? byId(String id) {
    final map = _box.get(id);
    return map == null ? null : Booking.fromMap(map as Map);
  }

  List<Booking> forStudent(String userId) =>
      _all().where((b) => b.studentId == userId).toList();

  List<Booking> forOwner(String userId) =>
      _all().where((b) => b.ownerId == userId).toList();

  /// True once the owner accepted a request from this student for this
  /// listing; used to reveal the owner's phone number.
  bool hasAccepted(String studentId, String propertyId) => _all().any((b) =>
      b.studentId == studentId &&
      b.propertyId == propertyId &&
      b.status == BookingStatus.accepted);

  bool hasPending(String studentId, String propertyId) => _all().any((b) =>
      b.studentId == studentId &&
      b.propertyId == propertyId &&
      b.status == BookingStatus.pending);

  Future<void> create({
    required String propertyId,
    required String studentId,
    required String ownerId,
    required String kind,
    required DateTime date,
    required String message,
  }) {
    final booking = Booking(
      id: const Uuid().v4(),
      propertyId: propertyId,
      studentId: studentId,
      ownerId: ownerId,
      kind: kind,
      date: date,
      message: message.trim(),
      createdAt: DateTime.now(),
    );
    return _box.put(booking.id, booking.toMap());
  }

  Future<void> setStatus(Booking booking, String status) {
    booking.status = status;
    return _box.put(booking.id, booking.toMap());
  }

  Future<void> deleteForProperty(String propertyId) async {
    final ids = _all()
        .where((b) => b.propertyId == propertyId)
        .map((b) => b.id)
        .toList();
    await _box.deleteAll(ids);
  }
}
