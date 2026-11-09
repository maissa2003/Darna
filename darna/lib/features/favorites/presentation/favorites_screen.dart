import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/common.dart';
import '../../home/presentation/auth_provider.dart';
import '../../listings/data/property_repository.dart';
import '../../listings/models/property.dart';
import '../../listings/presentation/property_card.dart';
import '../data/favorites_repository.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final favorites = FavoritesRepository();
    final properties = PropertyRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: ListenableBuilder(
        listenable: Listenable.merge(
            [favorites.listenable(), properties.listenable()]),
        builder: (context, _) {
          final items = favorites
              .propertyIds(user.id)
              .map(properties.byId)
              .whereType<Property>()
              .toList();
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'Pas encore de favoris',
              message:
                  'Appuie sur le ❤ d\'un logement pour le retrouver ici.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, i) => PropertyCard(property: items[i]),
          );
        },
      ),
    );
  }
}
