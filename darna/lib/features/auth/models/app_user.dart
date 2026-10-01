import 'package:hive_ce/hive.dart';
part 'app_user.g.dart';

@HiveType(typeId: 0)
class AppUser extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String fullName;
  @HiveField(2) String email;
  @HiveField(3) String phone;
  @HiveField(4) String passwordHash;
  @HiveField(5) String role;      // 'student' | 'owner'
  @HiveField(6) String gender;    // 'female' | 'male'
  @HiveField(7) String? universityId;
  @HiveField(8) String? avatarPath;
  @HiveField(9) DateTime createdAt;

  AppUser({
    required this.id, required this.fullName, required this.email,
    required this.phone, required this.passwordHash, required this.role,
    required this.gender, this.universityId, this.avatarPath,
    required this.createdAt,
  });
}