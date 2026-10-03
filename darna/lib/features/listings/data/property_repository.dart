import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/box_names.dart';
import '../models/property.dart';

class PropertyRepository {
  static Box<Property> get _box => Hive.box<Property>(BoxNames.properties);

  static List<Property> getAll({String query = ''}) {
    final normalized = query.trim().toLowerCase();
    return _box.values.where((property) {
      if (property.status != 'active') return false;
      if (normalized.isEmpty) return true;
      return '${property.title} ${property.city} ${property.governorate} ${property.type}'
          .toLowerCase()
          .contains(normalized);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Property> forOwner(String ownerId) =>
      _box.values.where((property) => property.ownerId == ownerId).toList();

  static Property? byId(String id) => _box.get(id);

  static Future<void> save(Property property) =>
      _box.put(property.id, property);

  static Future<void> delete(String id) => _box.delete(id);

  static Future<void> seedDemoData() async {
    if (_box.isNotEmpty) return;
    final demo = [
      _demo(
        'La Marsa, vue mer',
        'La Marsa',
        780,
        36.878,
        10.325,
        'Studio',
        'assets',
      ),
      _demo(
        'Le petit loft du Lac',
        'Les Berges du Lac',
        950,
        36.838,
        10.245,
        'Appartement',
        'assets',
      ),
      _demo(
        'Chambre lumineuse El Manar',
        'El Manar',
        420,
        36.833,
        10.158,
        'Chambre',
        'assets',
      ),
      _demo(
        'Studio calme proche campus',
        'Ariana',
        620,
        36.866,
        10.194,
        'Studio',
        'assets',
      ),
    ];
    for (final property in demo) {
      await _box.put(property.id, property);
    }
  }

  static Property _demo(
    String title,
    String city,
    double price,
    double lat,
    double lng,
    String type,
    String _,
  ) => Property(
    id: const Uuid().v4(),
    ownerId: 'demo-owner',
    title: title,
    description: 'Un logement soigneusement prepare, proche des transports et des campus.',
    type: type,
    pricePerMonth: price,
    governorate: 'Tunis',
    city: city,
    address: '$city, Tunis',
    lat: lat,
    lng: lng,
    rooms: type == 'Chambre' ? 1 : 2,
    surface: type == 'Chambre' ? 16 : 42,
    furnished: true,
    availableFrom: DateTime.now().add(const Duration(days: 10)),
    status: 'active',
    imageUrls: [_imageFor(city)],
    amenities: const ['Wi-Fi', 'Meuble', 'Climatisation'],
    createdAt: DateTime.now(),
  );

  static String _imageFor(String city) {
    const images = {
      'La Marsa':
          'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=900',
      'Les Berges du Lac':
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=900',
      'El Manar':
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=900',
      'Ariana':
          'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=900',
    };
    return images[city] ?? images.values.first;
  }
}
