import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../home/presentation/auth_provider.dart';
import '../data/property_repository.dart';
import '../models/property.dart';
import 'location_picker_screen.dart';

class PropertyFormScreen extends StatefulWidget {
  final Property? property;
  const PropertyFormScreen({super.key, this.property});
  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title,
      _description,
      _price,
      _city,
      _address,
      _surface;
  String _type = 'Studio';
  bool _furnished = true;
  int _rooms = 1;
  bool _saving = false;
  late LatLng _location;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _title = TextEditingController(text: p?.title);
    _description = TextEditingController(text: p?.description);
    _price = TextEditingController(text: p?.pricePerMonth.toInt().toString());
    _city = TextEditingController(text: p?.city);
    _address = TextEditingController(text: p?.address);
    _surface = TextEditingController(text: p?.surface.toInt().toString());
    _type = p?.type ?? 'Studio';
    _furnished = p?.furnished ?? true;
    _rooms = p?.rooms ?? 1;
    _location = LatLng(p?.lat ?? 36.8065, p?.lng ?? 10.1815);
    _images = [...?p?.imageUrls];
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _price,
      _city,
      _address,
      _surface,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins 3 photos du logement.')),
      );
      return;
    }
    setState(() => _saving = true);
    final user = context.read<AuthProvider>().user;
    if (user == null || user.role != 'owner') {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Seuls les proprietaires peuvent publier un logement.',
            ),
          ),
        );
      }
      return;
    }
    final old = widget.property;
    final property = Property(
      id: old?.id ?? const Uuid().v4(),
      ownerId: old?.ownerId ?? user.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      type: _type,
      pricePerMonth: double.parse(_price.text),
      governorate: 'Tunis',
      city: _city.text.trim(),
      address: _address.text.trim(),
      lat: _location.latitude,
      lng: _location.longitude,
      rooms: _rooms,
      surface: double.parse(_surface.text),
      furnished: _furnished,
      availableFrom: old?.availableFrom ?? DateTime.now(),
      status: old?.status ?? 'active',
      imageUrls: _images,
      amenities: old?.amenities ?? const ['Wi-Fi', 'Meuble'],
      createdAt: old?.createdAt ?? DateTime.now(),
    );
    await PropertyRepository.save(property);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickLocation() async {
    final selected = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: _location),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _location = selected);
    }
  }

  Future<void> _pickPhotos() async {
    final files = await ImagePicker().pickMultiImage(
      imageQuality: 82,
      maxWidth: 1400,
    );
    if (files.isEmpty) return;
    final encoded = <String>[];
    for (final file in files.take(6)) {
      final bytes = await file.readAsBytes();
      encoded.add('data:image/jpeg;base64,${base64Encode(bytes)}');
    }
    if (mounted)
      setState(() => _images = [..._images, ...encoded].take(6).toList());
  }

  Widget _photoPreview(String source, int index) {
    final image = source.startsWith('data:image/')
        ? Image.memory(base64Decode(source.split(',').last), fit: BoxFit.cover)
        : Image.network(source, fit: BoxFit.cover);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 100, height: 88, child: image),
        ),
        Positioned(
          top: 3,
          right: 3,
          child: GestureDetector(
            onTap: () => setState(() => _images.removeAt(index)),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.close, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Champ obligatoire' : null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.property == null ? 'Nouvelle annonce' : 'Modifier l annonce',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Presente ton logement',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Les informations claires attirent les bons locataires.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _title,
              decoration: _decoration('Titre de l annonce', Icons.title),
              validator: _required,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: _decoration('Description', Icons.notes_outlined),
              validator: _required,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Photos du logement (${_images.length}/3 minimum)',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickPhotos,
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 18,
                        ),
                        label: const Text('Ajouter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_images.isEmpty)
                    const Text(
                      'Ajoutez au moins 3 photos: salon, chambre et exterieur.',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < _images.length; i++)
                          _photoPreview(_images[i], i),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: _decoration('Type', Icons.home_work_outlined),
                    items: ['Chambre', 'Studio', 'Appartement']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _type = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: _decoration(
                      'Prix / mois',
                      Icons.payments_outlined,
                    ),
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Prix invalide'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _city,
                    decoration: _decoration('Ville', Icons.location_city),
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _surface,
                    keyboardType: TextInputType.number,
                    decoration: _decoration('Surface m2', Icons.square_foot),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalide' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _address,
              decoration: _decoration('Adresse', Icons.place_outlined),
              validator: _required,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF0E7C7B)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Position: ${_location.latitude.toStringAsFixed(5)}, ${_location.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickLocation,
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Choisir'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text('Nombre de pieces'),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      setState(() => _rooms = (_rooms - 1).clamp(1, 10)),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$_rooms',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _rooms = (_rooms + 1).clamp(1, 10)),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Logement meuble'),
              value: _furnished,
              onChanged: (value) => setState(() => _furnished = value),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Enregistrement...' : 'Publier l annonce'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
