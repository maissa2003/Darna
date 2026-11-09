import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../../core/constants/box_names.dart';
import '../models/review.dart';

class ReviewRepository {
  Box get _box => Hive.box(BoxNames.reviews);

  ValueListenable<Box> listenable() => _box.listenable();

  List<Review> forProperty(String propertyId) {
    final list = _box.values
        .map((m) => Review.fromMap(m as Map))
        .where((r) => r.propertyId == propertyId)
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Returns (average, count); average is 0 when there are no reviews.
  (double, int) summary(String propertyId) {
    final reviews = forProperty(propertyId);
    if (reviews.isEmpty) return (0, 0);
    final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return (total / reviews.length, reviews.length);
  }

  /// One review per user per listing: saving again replaces the old one.
  Future<void> save(Review review) =>
      _box.put('${review.userId}|${review.propertyId}', review.toMap());

  Future<void> deleteForProperty(String propertyId) async {
    final keys = _box.keys
        .cast<String>()
        .where((k) => k.endsWith('|$propertyId'))
        .toList();
    await _box.deleteAll(keys);
  }
}
