import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../constants/box_names.dart';
import '../utils/password_hasher.dart';
import '../../features/auth/models/app_user.dart';
import '../../features/listings/models/property.dart';
import '../../features/reviews/models/review.dart';
import '../../features/roommates/models/roommate_post.dart';

/// Fills an empty database with demo data so the app is not blank on
/// first launch. Demo accounts all use the password `darna123`
/// (see README).
class SeedService {
  static const demoPassword = 'darna123';

  static Future<void> run() async {
    final properties = Hive.box(BoxNames.properties);
    if (properties.isNotEmpty) return;

    final users = Hive.box<AppUser>(BoxNames.users);
    const uuid = Uuid();
    final now = DateTime.now();

    AppUser makeUser(String name, String email, String phone, String role,
        String gender) {
      final existing = users.values.where((u) => u.email == email);
      if (existing.isNotEmpty) return existing.first;
      final user = AppUser(
        id: uuid.v4(),
        fullName: name,
        email: email,
        phone: phone,
        passwordHash: PasswordHasher.hash(demoPassword),
        role: role,
        gender: gender,
        createdAt: now,
      );
      users.put(user.id, user);
      return user;
    }

    final sonia = makeUser('Sonia Ben Ali', 'proprio@darna.tn', '22123456',
        'owner', 'female');
    final karim = makeUser('Karim Trabelsi', 'karim@darna.tn', '98765432',
        'owner', 'male');
    final amira = makeUser('Amira Gharbi', 'amira@darna.tn', '55111222',
        'student', 'female');
    final youssef = makeUser('Youssef Mejri', 'youssef@darna.tn', '50333444',
        'student', 'male');

    final demo = <Property>[
      Property(
        id: uuid.v4(),
        ownerId: sonia.id,
        title: 'Chambre lumineuse près de la FST',
        description:
            'Chambre calme dans un appartement familial, à 5 minutes à pied '
            'de la Faculté des Sciences. Idéal pour une étudiante sérieuse.',
        type: PropertyType.room,
        city: 'Tunis',
        address: 'El Manar 2',
        university: 'Université de Tunis El Manar',
        price: 280,
        rooms: 1,
        genderPolicy: GenderPolicy.female,
        furnished: true,
        amenities: ['Wi-Fi', 'Eau chaude', 'Proche transport', 'Sécurité'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Property(
        id: uuid.v4(),
        ownerId: sonia.id,
        title: 'Studio moderne à Ariana',
        description:
            'Studio neuf entièrement équipé, cuisine américaine, '
            'proche du métro léger et des commerces.',
        type: PropertyType.studio,
        city: 'Ariana',
        address: 'Ennasr 1',
        university: 'Université de la Manouba',
        price: 520,
        rooms: 1,
        genderPolicy: GenderPolicy.any,
        furnished: true,
        amenities: ['Wi-Fi', 'Climatisation', 'Cuisine équipée', 'Balcon'],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Property(
        id: uuid.v4(),
        ownerId: karim.id,
        title: 'S+2 pour colocation à Sousse',
        description:
            'Appartement S+2 à Sahloul, parfait pour deux étudiants. '
            'Bus direct vers l\'université.',
        type: PropertyType.apartment,
        city: 'Sousse',
        address: 'Sahloul 4',
        university: 'Université de Sousse',
        price: 650,
        rooms: 2,
        genderPolicy: GenderPolicy.male,
        furnished: true,
        amenities: ['Wi-Fi', 'Machine à laver', 'Chauffage', 'Parking'],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Property(
        id: uuid.v4(),
        ownerId: karim.id,
        title: 'Place en colocation près de l\'ENIS',
        description:
            'Une place disponible dans une coloc sympa de 3 étudiants. '
            'Charges comprises.',
        type: PropertyType.shared,
        city: 'Sfax',
        address: 'Route de Soukra km 4',
        university: 'Université de Sfax',
        price: 220,
        rooms: 3,
        genderPolicy: GenderPolicy.male,
        furnished: true,
        amenities: ['Wi-Fi', 'Cuisine équipée', 'Eau chaude'],
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Property(
        id: uuid.v4(),
        ownerId: sonia.id,
        title: 'Studio cosy face à la mer',
        description:
            'Petit studio avec vue mer, à 10 minutes de la faculté de '
            'médecine de Monastir.',
        type: PropertyType.studio,
        city: 'Monastir',
        address: 'Skanes',
        university: 'Université de Monastir',
        price: 450,
        rooms: 1,
        genderPolicy: GenderPolicy.female,
        furnished: true,
        amenities: ['Wi-Fi', 'Climatisation', 'Balcon', 'Eau chaude'],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Property(
        id: uuid.v4(),
        ownerId: karim.id,
        title: 'Chambre économique à La Manouba',
        description:
            'Chambre simple et propre, proche du campus universitaire '
            'de la Manouba. Non meublée.',
        type: PropertyType.room,
        city: 'La Manouba',
        address: 'Campus Universitaire',
        university: 'Université de la Manouba',
        price: 180,
        rooms: 1,
        genderPolicy: GenderPolicy.any,
        furnished: false,
        amenities: ['Proche transport', 'Eau chaude'],
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      Property(
        id: uuid.v4(),
        ownerId: sonia.id,
        title: 'S+1 meublé à Ben Arous',
        description:
            'Appartement S+1 au calme, idéal pour un étudiant ou une '
            'étudiante en master. Proche de l\'ISET Radès.',
        type: PropertyType.apartment,
        city: 'Ben Arous',
        address: 'Mégrine',
        university: 'Université de Carthage',
        price: 580,
        rooms: 1,
        genderPolicy: GenderPolicy.any,
        furnished: true,
        amenities: ['Wi-Fi', 'Climatisation', 'Machine à laver', 'Parking'],
        lat: 36.7700,
        lng: 10.2330,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Property(
        id: uuid.v4(),
        ownerId: karim.id,
        title: 'Studio à 5 min de l\'INSAT',
        description:
            'Studio au Centre Urbain Nord, à quelques minutes à pied de '
            'l\'INSAT. Immeuble sécurisé avec ascenseur.',
        type: PropertyType.studio,
        city: 'Tunis',
        address: 'Centre Urbain Nord',
        university: 'INSAT',
        price: 600,
        rooms: 1,
        genderPolicy: GenderPolicy.any,
        furnished: true,
        amenities: ['Wi-Fi', 'Climatisation', 'Sécurité', 'Parking'],
        lat: 36.8455,
        lng: 10.1925,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Property(
        id: uuid.v4(),
        ownerId: sonia.id,
        title: 'Chambre chez l\'habitant près de l\'ENIT',
        description:
            'Chambre dans une maison calme au Belvédère, petit-déjeuner '
            'possible. Idéal pour une étudiante en ingénierie.',
        type: PropertyType.room,
        city: 'Tunis',
        address: 'Le Belvédère',
        university: 'ENIT',
        price: 250,
        rooms: 1,
        genderPolicy: GenderPolicy.female,
        furnished: true,
        amenities: ['Wi-Fi', 'Eau chaude', 'Machine à laver'],
        lat: 36.8270,
        lng: 10.1550,
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      Property(
        id: uuid.v4(),
        ownerId: karim.id,
        title: 'Colocation S+3 à El Menzah',
        description:
            'Une chambre libre dans une coloc de garçons, entre l\'ENIT, '
            'la FST et l\'INSAT. Métro à 3 minutes.',
        type: PropertyType.shared,
        city: 'Tunis',
        address: 'El Menzah 6',
        university: 'Université de Tunis El Manar',
        price: 230,
        rooms: 3,
        genderPolicy: GenderPolicy.male,
        furnished: true,
        amenities: ['Wi-Fi', 'Cuisine équipée', 'Proche transport'],
        lat: 36.8470,
        lng: 10.1700,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    for (final p in demo) {
      await properties.put(p.id, p.toMap());
    }

    final reviews = Hive.box(BoxNames.reviews);
    Future<void> review(Property p, AppUser u, int rating, String text) {
      final r = Review(
        id: uuid.v4(),
        propertyId: p.id,
        userId: u.id,
        userName: u.fullName,
        rating: rating,
        comment: text,
        createdAt: now.subtract(const Duration(hours: 5)),
      );
      return reviews.put('${u.id}|${p.id}', r.toMap());
    }

    await review(demo[0], amira, 5,
        'Propriétaire très gentille et chambre impeccable. Je recommande !');
    await review(demo[1], amira, 4, 'Studio propre et bien situé.');
    await review(demo[2], youssef, 4, 'Bon rapport qualité/prix.');
    await review(demo[4], amira, 5, 'Vue magnifique, quartier sûr.');

    final posts = Hive.box(BoxNames.roommatePosts);
    final demoPosts = [
      RoommatePost(
        id: uuid.v4(),
        userId: amira.id,
        kind: 'request',
        title: 'Cherche colocataire fille à Tunis',
        city: 'Tunis',
        university: 'Université de Tunis El Manar',
        budget: 300,
        gender: 'female',
        description:
            'Étudiante en 2ème année de médecine, je cherche une coloc calme '
            'près d\'El Manar à partir de septembre.',
        lifestyle: ['Non-fumeur', 'Calme', 'Studieux'],
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      RoommatePost(
        id: uuid.v4(),
        userId: youssef.id,
        kind: 'offer',
        title: 'Une chambre libre dans notre S+3 à Sousse',
        city: 'Sousse',
        university: 'Université de Sousse',
        budget: 250,
        gender: 'male',
        description:
            'On est deux étudiants en ingénierie, on cherche un troisième '
            'colocataire sympa. Appartement à Khezama.',
        lifestyle: ['Sociable', 'Propre', 'Couche-tard'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
    for (final p in demoPosts) {
      await posts.put(p.id, p.toMap());
    }
  }
}
