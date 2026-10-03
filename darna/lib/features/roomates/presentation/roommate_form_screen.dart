import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../home/presentation/auth_provider.dart';
import '../data/roommate_repository.dart';
import '../models/roommate_offer.dart';

class RoommateFormScreen extends StatefulWidget {
  final RoommateOffer? offer;
  const RoommateFormScreen({super.key, this.offer});

  @override
  State<RoommateFormScreen> createState() => _RoommateFormScreenState();
}

class _RoommateFormScreenState extends State<RoommateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _city;
  late final TextEditingController _area;
  late final TextEditingController _rent;
  late final TextEditingController _desc;
  late String _type;
  late String _roomType;
  late int _places;
  late DateTime _date;
  late bool _smoking;
  late bool _pets;
  late String _status;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;
    final me = context.read<AuthProvider>().user!;
    _city = TextEditingController(text: o?.city ?? me.city ?? '');
    _area = TextEditingController(text: o?.area ?? '');
    _rent = TextEditingController(text: o == null ? '' : '${o.rentShare.toInt()}');
    _desc = TextEditingController(text: o?.description ?? '');
    _type = o?.type ?? (me.gender == 'female' ? 'girls' : 'boys');
    _roomType = o?.roomType ?? 'single';
    _places = o?.placesAvailable ?? 1;
    _date = o?.availableFrom ?? DateTime.now().add(const Duration(days: 7));
    _smoking = o?.smokingAllowed ?? false;
    _pets = o?.petsAllowed ?? false;
    _status = o?.status ?? 'active';
  }

  @override
  void dispose() {
    _city.dispose();
    _area.dispose();
    _rent.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final me = context.read<AuthProvider>().user!;
    final o = widget.offer;
    final offer = RoommateOffer(
      id: o?.id ?? const Uuid().v4(),
      userId: me.id,
      type: _type,
      city: _city.text.trim(),
      area: _area.text.trim(),
      rentShare: double.parse(_rent.text.trim()),
      placesAvailable: _places,
      roomType: _roomType,
      availableFrom: _date,
      smokingAllowed: _smoking,
      petsAllowed: _pets,
      description: _desc.text.trim(),
      status: _status,
      createdAt: o?.createdAt ?? DateTime.now(),
    );
    await RoommateRepository.save(offer);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.offer == null
              ? "J'ai un logement"
              : 'Modifier mon offre')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Je cherche une colocataire / un colocataire'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'girls',
                        label: Text('Fille'),
                        icon: Icon(Icons.female)),
                    ButtonSegment(
                        value: 'boys',
                        label: Text('Garçon'),
                        icon: Icon(Icons.male)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _city,
                  decoration: const InputDecoration(
                      labelText: 'Ville', border: OutlineInputBorder()),
                  validator: required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _area,
                  decoration: const InputDecoration(
                      labelText: 'Quartier / adresse',
                      border: OutlineInputBorder()),
                  validator: required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rent,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Ma part du loyer (TND / mois)',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      (double.tryParse(v?.trim() ?? '') ?? 0) <= 0
                          ? 'Montant invalide'
                          : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _places,
                  decoration: const InputDecoration(
                      labelText: 'Places libres', border: OutlineInputBorder()),
                  items: [1, 2, 3, 4]
                      .map((n) =>
                          DropdownMenuItem(value: n, child: Text('$n')))
                      .toList(),
                  onChanged: (v) => setState(() => _places = v ?? 1),
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'single', label: Text('Individuelle')),
                    ButtonSegment(value: 'shared', label: Text('Partagée')),
                  ],
                  selected: {_roomType},
                  onSelectionChanged: (s) =>
                      setState(() => _roomType = s.first),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                      'Disponible dès le ${DateFormat('dd/MM/yyyy').format(_date)}'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fumeur accepté'),
                  value: _smoking,
                  onChanged: (v) => setState(() => _smoking = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Animaux acceptés'),
                  value: _pets,
                  onChanged: (v) => setState(() => _pets = v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _desc,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      labelText: 'Description et règles de vie',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder()),
                ),
                if (widget.offer != null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                        labelText: 'Statut', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'hidden', child: Text('Masquée')),
                      DropdownMenuItem(
                          value: 'found', child: Text('Colocataire trouvé')),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? 'active'),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                      onPressed: _save, child: const Text('Publier')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}