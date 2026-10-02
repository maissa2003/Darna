import 'package:hive_ce/hive.dart';

part 'property.g.dart';

@HiveType(typeId: 1)
class Property extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String ownerId;
  @HiveField(2)
  String title;
  @HiveField(3)
  String description;
  @HiveField(4)
  String type;
  @HiveField(5)
  double pricePerMonth;
  @HiveField(6)
  String governorate;
  @HiveField(7)
  String city;
  @HiveField(8)
  String address;
  @HiveField(9)
  double lat;
  @HiveField(10)
  double lng;
  @HiveField(11)
  int rooms;
  @HiveField(12)
  double surface;
  @HiveField(13)
  bool furnished;
  @HiveField(14)
  DateTime availableFrom;
  @HiveField(15)
  String status;
  @HiveField(16)
  List<String> imageUrls;
  @HiveField(17)
  List<String> amenities;
  @HiveField(18)
  DateTime createdAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.type,
    required this.pricePerMonth,
    required this.governorate,
    required this.city,
    required this.address,
    required this.lat,
    required this.lng,
    required this.rooms,
    required this.surface,
    required this.furnished,
    required this.availableFrom,
    required this.status,
    required this.imageUrls,
    required this.amenities,
    required this.createdAt,
  });
}
