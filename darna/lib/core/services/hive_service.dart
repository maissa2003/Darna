import 'package:hive_ce_flutter/hive_flutter.dart';
import '../constants/box_names.dart';
import '../../features/auth/models/app_user.dart';
import 'seed_service.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AppUserAdapter());
    await Hive.openBox<AppUser>(BoxNames.users);
    await Hive.openBox(BoxNames.session);
    // Other features store plain maps, so they need no adapters.
    await Future.wait([
      Hive.openBox(BoxNames.properties),
      Hive.openBox(BoxNames.favorites),
      Hive.openBox(BoxNames.bookings),
      Hive.openBox(BoxNames.reviews),
      Hive.openBox(BoxNames.roommatePosts),
      Hive.openBox(BoxNames.roommateContacts),
      Hive.openBox(BoxNames.payments),
    ]);
    await SeedService.run();
  }
}
