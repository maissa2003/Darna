import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../../core/constants/box_names.dart';
import '../models/roommate_offer.dart';

class RoommateRepository {
  static Box<RoommateOffer> get _box =>
      Hive.box<RoommateOffer>(BoxNames.roommateOffers);

  static List<RoommateOffer> getAll({String? type, String query = ''}) {
    final q = query.trim().toLowerCase();
    return _box.values.where((o) {
      if (o.status != 'active') return false;
      if (type != null && o.type != type) return false;
      if (q.isEmpty) return true;
      return '${o.city} ${o.area}'.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<RoommateOffer> forUser(String userId) =>
      _box.values.where((o) => o.userId == userId).toList();

  static Future<void> save(RoommateOffer offer) => _box.put(offer.id, offer);

  static Future<void> delete(String id) => _box.delete(id);
}