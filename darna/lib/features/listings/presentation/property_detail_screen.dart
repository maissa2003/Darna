import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../chat/presentation/chat_screen.dart';
import '../../home/presentation/auth_provider.dart';
import '../models/property.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final location = LatLng(property.lat, property.lng);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Logement'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.ios_share_outlined),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          property.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Color(0xFFDDEBE7),
                            child: Icon(
                              Icons.home_work_rounded,
                              size: 70,
                              color: Color(0xFF0E7C7B),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 18,
                          bottom: 18,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '1 / ${property.imageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.type.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0E7C7B),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          property.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 18,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                property.address,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoTile(
                              icon: Icons.bed_outlined,
                              label: '${property.rooms} piece(s)',
                            ),
                            _InfoTile(
                              icon: Icons.square_foot,
                              label: '${property.surface.toInt()} m2',
                            ),
                            _InfoTile(
                              icon: Icons.chair_outlined,
                              label: property.furnished
                                  ? 'Meuble'
                                  : 'Non meuble',
                            ),
                            ...property.amenities.map(
                              (item) => _InfoTile(
                                icon: Icons.check_circle_outline,
                                label: item,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Divider(),
                        const SizedBox(height: 20),
                        Text(
                          'A propos de ce logement',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          property.description,
                          style: const TextStyle(
                            height: 1.55,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Ou se trouve le logement ?',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 230,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: location,
                                initialZoom: 14,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'tn.student.darna',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: location,
                                      width: 58,
                                      height: 58,
                                      child: const Icon(
                                        Icons.location_pin,
                                        size: 52,
                                        color: Color(0xFF0E7C7B),
                                      ),
                                    ),
                                  ],
                                ),
                                const RichAttributionWidget(
                                  attributions: [
                                    TextSourceAttribution(
                                      'OpenStreetMap contributors',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          color: Colors.white,
          elevation: 12,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${property.pricePerMonth.toInt()} TND',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'par mois',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'Contacter le proprietaire',
                  onPressed: () {
                    final user = context.read<AuthProvider>().user;
                    if (user == null || user.role != 'student') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Connectez-vous comme etudiant pour contacter le proprietaire.',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          property: property,
                          studentId: user.id,
                          ownerId: property.ownerId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
                FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Demande envoyee au proprietaire.'),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Demander une visite'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoTile({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 17, color: const Color(0xFF0E7C7B)),
    label: Text(label),
    backgroundColor: const Color(0xFFEAF4F1),
    side: BorderSide.none,
  );
}
