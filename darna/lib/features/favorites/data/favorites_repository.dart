import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../../core/constants/box_names.dart';

class FavoritesRepository {
  Box get _box => Hive.box(BoxNames.favorites);

  ValueListenable<Box> listenable() => _box.listenable();

  String _key(String userId, String propertyId) => '$userId|$propertyId';

  bool isFavorite(String userId, String propertyId) =>
      _box.containsKey(_key(userId, propertyId));

  Future<void> toggle(String userId, String propertyId) {
    final key = _key(userId, propertyId);
    return _box.containsKey(key) ? _box.delete(key) : _box.put(key, true);
  }

  List<String> propertyIds(String userId) => _box.keys
      .cast<String>()
      .where((k) => k.startsWith('$userId|'))
      .map((k) => k.split('|').last)
      .toList();

  Future<void> deleteForProperty(String propertyId) async {
    final keys = _box.keys
        .cast<String>()
        .where((k) => k.endsWith('|$propertyId'))
        .toList();
    await _box.deleteAll(keys);
  }
}
