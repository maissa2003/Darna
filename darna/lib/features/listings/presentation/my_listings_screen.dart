import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../home/presentation/auth_provider.dart';
import '../data/property_repository.dart';
import '../models/property.dart';
import 'property_detail_screen.dart';
import 'property_form_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  Future<void> _open(Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  Future<void> _delete(Property p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la publication ?'),
        content: Text(p.title),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      await PropertyRepository.delete(p.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final items = PropertyRepository.forOwner(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes publications')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(const PropertyFormScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle annonce'),
      ),
      body: items.isEmpty
          ? const Center(child: Text("Vous n'avez encore rien publié."))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final p = items[i];
                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: p.imageUrls.isEmpty
                          ? const SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(Icons.home_work_outlined))
                          : Image.network(
                              p.imageUrls.first,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Icon(Icons.home_work_outlined)),
                            ),
                    ),
                    title: Text(p.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${p.pricePerMonth.toInt()} TND / mois • ${p.city}\n'
                        '${p.status == 'active' ? 'Active' : 'Masquée'}'),
                    isThreeLine: true,
                    onTap: () => _open(PropertyDetailScreen(property: p)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Modifier',
                          onPressed: () =>
                              _open(PropertyFormScreen(property: p)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Supprimer',
                          onPressed: () => _delete(p),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}