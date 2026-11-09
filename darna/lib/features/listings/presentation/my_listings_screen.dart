import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/common.dart';
import '../../home/presentation/auth_provider.dart';
import '../data/property_repository.dart';
import 'property_card.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final repo = PropertyRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Mes annonces')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/property/new'),
        icon: const Icon(Icons.add_home_outlined),
        label: const Text('Publier'),
      ),
      body: ValueListenableBuilder(
        valueListenable: repo.listenable(),
        builder: (context, _, _) {
          final mine = repo.byOwner(user.id);
          if (mine.isEmpty) {
            return EmptyState(
              icon: Icons.add_home_work_outlined,
              title: 'Aucune annonce',
              message:
                  'Publie ton premier logement et des étudiants pourront te contacter.',
              action: FilledButton.icon(
                onPressed: () => context.push('/property/new'),
                icon: const Icon(Icons.add),
                label: const Text('Publier une annonce'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: mine.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, i) => PropertyCard(property: mine[i]),
          );
        },
      ),
    );
  }
}
