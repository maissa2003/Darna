import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/tunisia.dart';
import '../../../core/widgets/common.dart';
import '../../home/presentation/auth_provider.dart';
import '../data/roommate_repository.dart';
import '../models/roommate_post.dart';

class RoommateFormScreen extends StatefulWidget {
  const RoommateFormScreen({super.key});

  @override
  State<RoommateFormScreen> createState() => _RoommateFormScreenState();
}

class _RoommateFormScreenState extends State<RoommateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _budget = TextEditingController();
  String _kind = 'request';
  String _city = Tunisia.cities.first;
  String? _university;
  final Set<String> _lifestyle = {};

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user!;
    await RoommateRepository().savePost(RoommatePost(
      id: const Uuid().v4(),
      userId: user.id,
      kind: _kind,
      title: _title.text.trim(),
      city: _city,
      university: _university ?? '',
      budget: int.parse(_budget.text.trim()),
      gender: user.gender,
      description: _description.text.trim(),
      lifestyle: _lifestyle.toList(),
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    showMessage(context, 'Annonce de colocation publiée 🎉');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Annonce de colocation')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'request',
                    label: Text('Je cherche'),
                    icon: Icon(Icons.search)),
                ButtonSegment(
                    value: 'offer',
                    label: Text('Je propose'),
                    icon: Icon(Icons.home_outlined)),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _title,
              decoration: InputDecoration(
                labelText: 'Titre',
                hintText: _kind == 'offer'
                    ? 'Ex : Chambre libre dans S+2 à Ennasr'
                    : 'Ex : Cherche coloc près de l\'ENIT',
              ),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'Titre trop court'
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _city,
              decoration: const InputDecoration(labelText: 'Ville'),
              items: [
                for (final c in Tunisia.cities)
                  DropdownMenuItem(value: c, child: Text(c))
              ],
              onChanged: (v) => setState(() => _city = v!),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(
              initialValue: _university,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Université'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Aucune')),
                for (final u in Tunisia.universities)
                  DropdownMenuItem(value: u, child: Text(u))
              ],
              onChanged: (v) => setState(() => _university = v),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Budget', suffixText: 'DT / mois'),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                return (n == null || n <= 0) ? 'Budget invalide' : null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Présentation',
                alignLabelWithHint: true,
                hintText: 'Tes études, ton rythme, ce que tu recherches…',
              ),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Ajoute quelques mots'
                  : null,
            ),
            const SizedBox(height: 20),
            const SectionTitle('Mon mode de vie'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final l in Tunisia.lifestyles)
                  FilterChip(
                    label: Text(l),
                    selected: _lifestyle.contains(l),
                    onSelected: (on) => setState(
                        () => on ? _lifestyle.add(l) : _lifestyle.remove(l)),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: _save, child: const Text('Publier')),
          ],
        ),
      ),
    );
  }
}
