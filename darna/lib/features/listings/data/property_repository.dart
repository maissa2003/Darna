import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../../core/constants/box_names.dart';
import '../models/property.dart';

class PropertyFilter {
  final String query;
  final String? city;
  final String? type;
  final int? maxPrice;
  final String? genderPolicy;
  final bool furnishedOnly;

  const PropertyFilter({
    this.query = '',
    this.city,
    this.type,
    this.maxPrice,
    this.genderPolicy,
    this.furnishedOnly = false,
  });

  int get activeCount => [
        type != null,
        maxPrice != null,
        genderPolicy != null,
        furnishedOnly,
      ].where((x) => x).length;

  bool matches(Property p) {
    if (!p.available) return false;
    if (city != null && p.city != city) return false;
    if (type != null && p.type != type) return false;
    if (maxPrice != null && p.price > maxPrice!) return false;
    if (furnishedOnly && !p.furnished) return false;
    // A girls-only search should still show mixed listings.
    if (genderPolicy != null &&
        p.genderPolicy != GenderPolicy.any &&
        p.genderPolicy != genderPolicy) {
      return false;
    }
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [p.title, p.city, p.address, p.university, p.description]
        .any((field) => field.toLowerCase().contains(q));
  }
}

class PropertyRepository {
  Box get _box => Hive.box(BoxNames.properties);

  ValueListenable<Box> listenable() => _box.listenable();

  List<Property> all() {
    final list = _box.values.map((m) => Property.fromMap(m as Map)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Property> search(PropertyFilter filter) =>
      all().where(filter.matches).toList();

  List<Property> byOwner(String ownerId) =>
      all().where((p) => p.ownerId == ownerId).toList();

  Property? byId(String id) {
    final map = _box.get(id);
    return map == null ? null : Property.fromMap(map as Map);
  }

  Future<void> save(Property p) => _box.put(p.id, p.toMap());

  Future<void> delete(String id) => _box.delete(id);
}
