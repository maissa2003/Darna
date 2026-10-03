import 'package:hive_ce/hive.dart';

part 'roommate_offer.g.dart';

@HiveType(typeId: 3)
class RoommateOffer extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String userId;
  @HiveField(2)
  String type; // 'girls' | 'boys'
  @HiveField(3)
  String city;
  @HiveField(4)
  String area;
  @HiveField(5)
  double rentShare;
  @HiveField(6)
  int placesAvailable;
  @HiveField(7)
  String roomType; // 'single' | 'shared'
  @HiveField(8)
  DateTime availableFrom;
  @HiveField(9)
  bool smokingAllowed;
  @HiveField(10)
  bool petsAllowed;
  @HiveField(11)
  String description;
  @HiveField(12)
  String status; // 'active' | 'hidden' | 'found'
  @HiveField(13)
  DateTime createdAt;

  RoommateOffer({
    required this.id,
    required this.userId,
    required this.type,
    required this.city,
    required this.area,
    required this.rentShare,
    required this.placesAvailable,
    required this.roomType,
    required this.availableFrom,
    required this.smokingAllowed,
    required this.petsAllowed,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}