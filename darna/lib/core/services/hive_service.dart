import 'package:hive_ce_flutter/hive_flutter.dart';
import '../constants/box_names.dart';
import '../../features/auth/models/app_user.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AppUserAdapter());
    await Hive.openBox<AppUser>(BoxNames.users);
    await Hive.openBox(BoxNames.session);
    // teammates add their adapters and boxes here
  }
}