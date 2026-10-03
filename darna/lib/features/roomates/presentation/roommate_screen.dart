import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/box_names.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/models/app_user.dart';
import '../../home/presentation/auth_provider.dart';
import '../data/roommate_repository.dart';
import '../models/roommate_offer.dart';
import 'roommate_form_screen.dart';

class RoommateScreen extends StatefulWidget {
  const RoommateScreen({super.key});

  @override
  State<RoommateScreen> createState() => _RoommateScreenState();
}

class _RoommateScreenState extends State<RoommateScreen> {
  static const _teal = Color(0xFF0E7C7B);
  String? _type; // null = all
  String _query = '';
  bool _initialized = false;

  Future<void> _openForm([RoommateOffer? offer]) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RoommateFormScreen(offer: offer)));
    if (mounted) setState(() {});
  }

  void _showOffer(RoommateOffer o) {
    final owner = Hive.box<AppUser>(BoxNames.users).get(o.userId);
    final me = context.read<AuthProvider>().user!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(
                      data: owner?.avatarPath,
                      name: owner?.fullName ?? '?',
                      radius: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(owner?.fullName ?? 'Utilisateur',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('${o.area}, ${o.city}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(o.description.isEmpty ? 'Pas de description.' : o.description),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('${o.rentShare.toInt()} TND / mois')),
                  Chip(label: Text('${o.placesAvailable} place(s)')),
                  Chip(
                      label: Text(o.roomType == 'single'
                          ? 'Chambre individuelle'
                          : 'Chambre partagée')),
                  Chip(
                      label: Text('Dès le '
                          '${DateFormat('dd/MM/yyyy').format(o.availableFrom)}')),
                  Chip(label: Text(o.smokingAllowed ? 'Fumeur OK' : 'Non fumeur')),
                  Chip(label: Text(o.petsAllowed ? 'Animaux OK' : 'Pas d\'animaux')),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: o.userId == me.id
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Demande de contact : bientôt disponible')),
                          );
                        },
                  icon: const Icon(Icons.waving_hand_outlined),
                  label: Text(o.userId == me.id
                      ? 'Ceci est votre offre'
                      : 'Demander à rejoindre'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user!;
    if (!_initialized) {
      _type = me.gender == 'female' ? 'girls' : 'boys';
      _initialized = true;
    }
    final offers = RoommateRepository.getAll(type: _type, query: _query);
    final mine = RoommateRepository.forUser(me.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),
      appBar: AppBar(title: const Text('Colocation')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text("J'ai un logement"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Ville ou quartier...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tous'),
                selected: _type == null,
                onSelected: (_) => setState(() => _type = null),
              ),
              ChoiceChip(
                label: const Text('Filles'),
                selected: _type == 'girls',
                onSelected: (_) => setState(() => _type = 'girls'),
              ),
              ChoiceChip(
                label: const Text('Garçons'),
                selected: _type == 'boys',
                onSelected: (_) => setState(() => _type = 'boys'),
              ),
            ],
          ),
          if (mine.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Mes offres',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final o in mine)
              Card(
                child: ListTile(
                  title: Text('${o.area}, ${o.city}'),
                  subtitle: Text('${o.rentShare.toInt()} TND • '
                      '${o.status == 'active' ? 'Active' : o.status == 'found' ? 'Colocataire trouvé' : 'Masquée'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _openForm(o)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () async {
                          await RoommateRepository.delete(o.id);
                          if (mounted) setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 20),
          Text('${offers.length} offre(s) disponible(s)',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (offers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Aucune offre pour ces filtres.')),
            ),
          for (final o in offers) _OfferCard(offer: o, onTap: () => _showOffer(o)),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final RoommateOffer offer;
  final VoidCallback onTap;
  const _OfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final owner = Hive.box<AppUser>(BoxNames.users).get(offer.userId);
    final isGirls = offer.type == 'girls';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 1.5,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                UserAvatar(
                    data: owner?.avatarPath,
                    name: owner?.fullName ?? '?',
                    radius: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(owner?.fullName ?? 'Utilisateur',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('${offer.area}, ${offer.city}',
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Text('${offer.rentShare.toInt()} TND / mois • '
                          '${offer.placesAvailable} place(s)',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Icon(isGirls ? Icons.female : Icons.male,
                    color: isGirls ? Colors.pink : Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}