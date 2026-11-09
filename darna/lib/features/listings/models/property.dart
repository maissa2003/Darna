import 'dart:typed_data';

class PropertyType {
  static const room = 'room';
  static const studio = 'studio';
  static const apartment = 'apartment';
  static const shared = 'shared';

  static const all = [room, studio, apartment, shared];

  static String label(String type) => switch (type) {
        room => 'Chambre',
        studio => 'Studio',
        apartment => 'Appartement',
        shared => 'Colocation',
        _ => type,
      };
}

class GenderPolicy {
  static const any = 'any';
  static const female = 'female';
  static const male = 'male';

  static const all = [any, female, male];

  static String label(String policy) => switch (policy) {
        female => 'Filles uniquement',
        male => 'Garçons uniquement',
        _ => 'Mixte',
      };
}

/// Stored in Hive as a plain map, so no generated adapter is needed.
class Property {
  final String id;
  final String ownerId;
  String title;
  String description;
  String type;
  String city;
  String address;
  String university;
  int price; // TND / month
  int rooms;
  String genderPolicy;
  bool furnished;
  bool available;
  List<String> amenities;
  List<Uint8List> images;
  // Map position; null for listings saved before the map existed.
  double? lat;
  double? lng;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.type,
    required this.city,
    required this.address,
    required this.university,
    required this.price,
    required this.rooms,
    required this.genderPolicy,
    required this.furnished,
    this.available = true,
    this.amenities = const [],
    this.images = const [],
    this.lat,
    this.lng,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'type': type,
        'city': city,
        'address': address,
        'university': university,
        'price': price,
        'rooms': rooms,
        'genderPolicy': genderPolicy,
        'furnished': furnished,
        'available': available,
        'amenities': amenities,
        'images': images,
        'lat': lat,
        'lng': lng,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Property.fromMap(Map map) => Property(
        id: map['id'] as String,
        ownerId: map['ownerId'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        type: map['type'] as String,
        city: map['city'] as String,
        address: map['address'] as String? ?? '',
        university: map['university'] as String? ?? '',
        price: map['price'] as int,
        rooms: map['rooms'] as int? ?? 1,
        genderPolicy: map['genderPolicy'] as String? ?? GenderPolicy.any,
        furnished: map['furnished'] as bool? ?? false,
        available: map['available'] as bool? ?? true,
        amenities: List<String>.from(map['amenities'] as List? ?? const []),
        images: List<Uint8List>.from(map['images'] as List? ?? const []),
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}
