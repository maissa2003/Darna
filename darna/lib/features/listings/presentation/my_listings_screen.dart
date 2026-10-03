import 'dart:convert';
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
  static const _teal = Color(0xFF0E7C7B);

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  Future<void> _toggle(Property p) async {
    p.status = p.status == 'active' ? 'hidden' : 'active';
    await PropertyRepository.save(p);
    if (mounted) setState(() {});
  }

  Future<void> _delete(Property p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline, size: 32),
        title: const Text('Supprimer cette annonce ?'),
        content: Text(p.title, textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      await PropertyRepository.delete(p.id);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Annonce supprimée')));
      }
    }
  }

  Widget _cover(Property p) {
    const placeholder = ColoredBox(
      color: Color(0xFFDDEBE7),
      child: Center(
          child: Icon(Icons.home_work_rounded, size: 48, color: _teal)),
    );
    if (p.imageUrls.isEmpty) return placeholder;
    final src = p.imageUrls.first;
    if (src.startsWith('http')) {
      return Image.network(src,
          fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder);
    }
    try {
      return Image.memory(base64Decode(src),
          fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder);
    } catch (_) {
      return placeholder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final items = PropertyRepository.forOwner(user.id)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final active = items.where((p) => p.status == 'active').length;
    final hidden = items.length - active;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        onPressed: () => _open(const PropertyFormScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle annonce'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: _teal,
            foregroundColor: Colors.white,
            title: const Text('Mes publications'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0E7C7B), Color(0xFF16A09E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 96, 20, 16),                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bonjour, ${user.fullName.split(' ').first}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('Gère tes logements',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _Stat(label: 'Total', value: '${items.length}'),
                        const SizedBox(width: 10),
                        _Stat(label: 'Actives', value: '$active'),
                        const SizedBox(width: 10),
                        _Stat(label: 'Masquées', value: '$hidden'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_home_work_outlined,
                          size: 80, color: _teal.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text('Aucune annonce pour le moment',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      const Text(
                        'Publie ton premier logement pour recevoir des messages d\'étudiants.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _ListingCard(
                  property: items[i],
                  cover: _cover(items[i]),
                  onOpen: () => _open(PropertyDetailScreen(property: items[i])),
                  onEdit: () => _open(PropertyFormScreen(property: items[i])),
                  onDelete: () => _delete(items[i]),
                  onToggle: () => _toggle(items[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      );
}

class _ListingCard extends StatelessWidget {
  final Property property;
  final Widget cover;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _ListingCard({
    required this.property,
    required this.cover,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = property.status == 'active';
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  cover,
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(
                      text: isActive ? 'Active' : 'Masquée',
                      color: isActive ? Colors.green : Colors.grey.shade700,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: _Badge(
                      text: '${property.pricePerMonth.toInt()} TND / mois',
                      color: const Color(0xFF0E7C7B),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.type.toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF0E7C7B),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(property.city,
                            style: const TextStyle(color: Colors.black54)),
                      ),
                      Text('${property.rooms} pièce(s) • '
                          '${property.surface.toInt()} m²',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  Switch(value: isActive, onChanged: (_) => onToggle()),
                  Text(isActive ? 'Visible' : 'Masquée',
                      style: const TextStyle(fontSize: 13)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Modifier'),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Supprimer',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      );
}