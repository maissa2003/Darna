import 'package:hive_ce_flutter/hive_flutter.dart';

import '../constants/box_names.dart';
import '../../features/auth/models/app_user.dart';
import '../../features/listings/models/property.dart';
import '../../features/listings/data/property_repository.dart';
import '../../features/chat/models/chat_message.dart';
import '../../features/roomates/models/roommate_offer.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AppUserAdapter());
    Hive.registerAdapter(PropertyAdapter());
    Hive.registerAdapter(RoommateOfferAdapter());
    await Hive.openBox<RoommateOffer>(BoxNames.roommateOffers);
    Hive.registerAdapter(ChatMessageAdapter());
    await Hive.openBox<AppUser>(BoxNames.users);
    await Hive.openBox(BoxNames.session);
    await Hive.openBox<Property>(BoxNames.properties);
    await Hive.openBox<ChatMessage>(BoxNames.chatMessages);
    await PropertyRepository.seedDemoData();
  }
}
