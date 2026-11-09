import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/geo.dart';
import '../../../core/constants/tunisia.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../home/presentation/auth_provider.dart';
import '../data/property_repository.dart';
import '../models/property.dart';
import 'location_map.dart';

/// Create a listing, or edit one when [propertyId] is given.
class PropertyFormScreen extends StatefulWidget {
  final String? propertyId;
  const PropertyFormScreen({super.key, this.propertyId});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  static const _maxPhotos = 6;

  final _repo = PropertyRepository();
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _price = TextEditingController();
  final _rooms = TextEditingController(text: '1');

  Property? _existing;
  String _type = PropertyType.room;
  String _city = Tunisia.cities.first;
  String? _university;
  String _gender = GenderPolicy.any;
  bool _furnished = true;
  bool _available = true;
  final Set<String> _amenities = {};
  final List<Uint8List> _images = [];
  bool _saving = false;
  final _mapController = MapController();
  // Set once the owner taps the map; until then the pin follows the
  // chosen university / city.
  LatLng? _pickedPosition;

  LatLng get _position =>
      _pickedPosition ??
      Geo.universities[_university] ??
      Geo.cities[_city] ??
      Geo.tunisCenter;

  void _recenterIfNotPicked() {
    if (_pickedPosition == null) {
      _mapController.move(_position, _mapController.camera.zoom);
    }
  }

  @override
  void initState() {
    super.initState();
    final id = widget.propertyId;
    if (id == null) return;
    final p = _repo.byId(id);
    if (p == null) return;
    _existing = p;
    _title.text = p.title;
    _description.text = p.description;
    _address.text = p.address;
    _price.text = '${p.price}';
    _rooms.text = '${p.rooms}';
    _type = p.type;
    _city = p.city;
    _university = p.university.isEmpty ? null : p.university;
    _gender = p.genderPolicy;
    _furnished = p.furnished;
    _available = p.available;
    _amenities.addAll(p.amenities);
    _images.addAll(p.images);
    _pickedPosition = Geo.positionOf(p);
  }

  @override
  void dispose() {
    for (final c in [_title, _description, _address, _price, _rooms]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final files = await ImagePicker().pickMultiImage(
        maxWidth: 1280,
        imageQuality: 70,
        limit: _maxPhotos - _images.length,
      );
      for (final f in files.take(_maxPhotos - _images.length)) {
        final bytes = await f.readAsBytes();
        setState(() => _images.add(bytes));
      }
    } catch (_) {
      if (mounted) showMessage(context, 'Impossible d\'ajouter la photo.');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final user = context.read<AuthProvider>().user!;
    final property = Property(
      id: _existing?.id ?? const Uuid().v4(),
      ownerId: _existing?.ownerId ?? user.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      type: _type,
      city: _city,
      address: _address.text.trim(),
      university: _university ?? '',
      price: int.parse(_price.text.trim()),
      rooms: int.parse(_rooms.text.trim()),
      genderPolicy: _gender,
      furnished: _furnished,
      available: _available,
      amenities: _amenities.toList(),
      images: List.of(_images),
      lat: _position.latitude,
      lng: _position.longitude,
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    await _repo.save(property);
    if (!mounted) return;
    showMessage(context,
        _existing == null ? 'Annonce publiée 🎉' : 'Annonce mise à jour');
    context.pop();
  }

  String _distanceHint() {
    final nearest = Geo.nearestUniversity(_position);
    if (nearest == null) return 'Emplacement enregistré.';
    return 'À ${Geo.formatKm(nearest.$2)} de ${nearest.$1}.';
  }

  String? _positiveInt(String? v, String label) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null || n <= 0) return '$label invalide';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editing = _existing != null;
    return Scaffold(
      appBar: AppBar(
          title: Text(editing ? 'Modifier l\'annonce' : 'Nouvelle annonce')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const SectionTitle('Photos'),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_images.length < _maxPhotos)
                    InkWell(
                      onTap: _pickImages,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.blush,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.rose),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                color: AppColors.rose),
                            SizedBox(height: 4),
                            Text('Ajouter',
                                style: TextStyle(color: AppColors.roseDark)),
                          ],
                        ),
                      ),
                    ),
                  for (var i = 0; i < _images.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_images[i],
                                width: 100, height: 100, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _images.removeAt(i)),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.close,
                                    size: 16, color: AppColors.plum),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Informations'),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                  labelText: 'Titre de l\'annonce',
                  hintText: 'Ex : Studio calme près de l\'INSAT'),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'Titre trop court'
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                for (final t in PropertyType.all)
                  DropdownMenuItem(value: t, child: Text(PropertyType.label(t)))
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Loyer', suffixText: 'DT / mois'),
                    validator: (v) => _positiveInt(v, 'Loyer'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    controller: _rooms,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Pièces'),
                    validator: (v) => _positiveInt(v, 'Nombre'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  hintText: 'Décris le logement, le quartier, les règles…'),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Localisation'),
            DropdownButtonFormField<String>(
              initialValue: _city,
              decoration: const InputDecoration(labelText: 'Ville'),
              items: [
                for (final c in Tunisia.cities)
                  DropdownMenuItem(value: c, child: Text(c))
              ],
              onChanged: (v) {
                setState(() => _city = v!);
                _recenterIfNotPicked();
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(
                  labelText: 'Quartier / adresse',
                  prefixIcon: Icon(Icons.place_outlined)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Adresse obligatoire' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(
              initialValue: _university,
              isExpanded: true,
              decoration:
                  const InputDecoration(labelText: 'Université à proximité'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Aucune')),
                for (final u in Tunisia.universities)
                  DropdownMenuItem(value: u, child: Text(u))
              ],
              onChanged: (v) {
                setState(() => _university = v);
                _recenterIfNotPicked();
              },
            ),
            const SizedBox(height: 16),
            LocationMap(
              point: _position,
              controller: _mapController,
              onTap: (point) => setState(() => _pickedPosition = point),
            ),
            const SizedBox(height: 6),
            Text(
              _pickedPosition == null
                  ? 'Touche la carte pour placer ton logement exactement.'
                  : _distanceHint(),
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Pour qui ?'),
            SegmentedButton<String>(
              segments: [
                for (final g in GenderPolicy.all)
                  ButtonSegment(
                    value: g,
                    label: Text(switch (g) {
                      GenderPolicy.female => 'Filles',
                      GenderPolicy.male => 'Garçons',
                      _ => 'Mixte',
                    }),
                  ),
              ],
              selected: {_gender},
              onSelectionChanged: (s) => setState(() => _gender = s.first),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Meublé'),
              value: _furnished,
              onChanged: (v) => setState(() => _furnished = v),
            ),
            if (editing)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Disponible'),
                subtitle: const Text('Désactive pour masquer l\'annonce'),
                value: _available,
                onChanged: (v) => setState(() => _available = v),
              ),
            const SizedBox(height: 16),
            const SectionTitle('Équipements'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in Tunisia.amenities)
                  FilterChip(
                    label: Text(a),
                    selected: _amenities.contains(a),
                    onSelected: (on) => setState(
                        () => on ? _amenities.add(a) : _amenities.remove(a)),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(editing ? 'Enregistrer' : 'Publier l\'annonce'),
            ),
          ],
        ),
      ),
    );
  }
}
