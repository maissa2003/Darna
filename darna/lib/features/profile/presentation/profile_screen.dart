import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/tunisia.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../bookings/data/booking_repository.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../home/presentation/auth_provider.dart';
import '../../listings/data/property_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    final isOwner = user.role == 'owner';
    final properties = PropertyRepository();
    final bookings = BookingRepository();
    final favorites = FavoritesRepository();

    // The profile tab stays alive in the IndexedStack, so listen to the
    // boxes instead of computing the counts once.
    final statsRow = ListenableBuilder(
      listenable: Listenable.merge([
        properties.listenable(),
        bookings.listenable(),
        favorites.listenable(),
      ]),
      builder: (context, _) {
        final stats = isOwner
            ? [
                ('Annonces', properties.byOwner(user.id).length),
                ('Demandes', bookings.forOwner(user.id).length),
              ]
            : [
                ('Favoris', favorites.propertyIds(user.id).length),
                ('Demandes', bookings.forStudent(user.id).length),
              ];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final (label, value) in stats)
              Container(
                width: 110,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text('$value',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    Text(label, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
          ],
        );
      },
    );

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 28, 20, 28),
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: Text(initials(user.fullName),
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.rose)),
                ),
                const SizedBox(height: 12),
                Text(user.fullName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  isOwner ? 'Propriétaire' : 'Étudiant·e',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 18),
                statsRow,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Column(
                children: [
                  _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email),
                  const Divider(height: 1),
                  _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: '+216 ${user.phone}'),
                  const Divider(height: 1),
                  _InfoRow(
                      icon: user.gender == 'female'
                          ? Icons.female
                          : Icons.male,
                      label: 'Genre',
                      value: user.gender == 'female' ? 'Fille' : 'Garçon'),
                  if (!isOwner) ...[
                    const Divider(height: 1),
                    _InfoRow(
                        icon: Icons.school_outlined,
                        label: 'Université',
                        value: user.universityId ?? 'Non renseignée'),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    backgroundColor: AppColors.cream,
                    builder: (_) => const _EditProfileSheet(),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier mon profil'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await confirmDialog(
                        context, 'Se déconnecter ?', 'À bientôt sur Darna 🌸',
                        confirm: 'Déconnexion');
                    if (ok) await auth.logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Déconnexion'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.rose),
        title: Text(label,
            style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        subtitle: Text(value,
            style: const TextStyle(
                color: AppColors.plum,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _user = context.read<AuthProvider>().user!;
  late final _name = TextEditingController(text: _user.fullName);
  late final _phone = TextEditingController(text: _user.phone);
  late String? _university = _user.universityId;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().updateProfile(
        fullName: _name.text, phone: _phone.text, universityId: _university);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Modifier mon profil',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Entrez votre nom complet'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixText: '+216 ',
                  prefixIcon: Icon(Icons.phone_outlined)),
              validator: (v) => RegExp(r'^\d{8}$').hasMatch(v?.trim() ?? '')
                  ? null
                  : 'Numéro invalide (8 chiffres)',
            ),
            if (_user.role == 'student') ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String?>(
                initialValue: _university,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'Université',
                    prefixIcon: Icon(Icons.school_outlined)),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Non renseignée')),
                  for (final u in Tunisia.universities)
                    DropdownMenuItem(value: u, child: Text(u))
                ],
                onChanged: (v) => setState(() => _university = v),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
  }
}
