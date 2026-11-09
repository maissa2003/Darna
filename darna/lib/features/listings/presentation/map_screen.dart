import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/geo.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/map_widgets.dart';
import '../data/property_repository.dart';
import '../models/property.dart';

/// Map of every university with the homes around it. Tapping a university
/// highlights a circle around it and lists the nearby homes, closest first.
class MapScreen extends StatefulWidget {
  final String? initialUniversity;
  const MapScreen({super.key, this.initialUniversity});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _repo = PropertyRepository();
  final _map = MapController();
  final _pages = PageController(viewportFraction: 0.88);
  String? _university;
  String? _selectedPropertyId;

  @override
  void initState() {
    super.initState();
    _university = Geo.universities.containsKey(widget.initialUniversity)
        ? widget.initialUniversity
        : null;
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _selectUniversity(String name) {
    setState(() {
      _university = name;
      _selectedPropertyId = null;
    });
    _map.move(Geo.universities[name]!, 14);
    if (_pages.hasClients) _pages.jumpToPage(0);
  }

  void _selectProperty(Property p, List<Property> shown) {
    setState(() => _selectedPropertyId = p.id);
    final index = shown.indexWhere((x) => x.id == p.id);
    if (index >= 0 && _pages.hasClients) {
      _pages.animateToPage(index,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  /// Homes to list at the bottom: around the selected university, or all of
  /// them when none is selected.
  List<(Property, double?)> _listed(List<Property> all) {
    final uni = _university;
    if (uni == null) return [for (final p in all) (p, null)];
    final center = Geo.universities[uni]!;
    final list = [
      for (final p in all) (p, Geo.km(center, Geo.positionOf(p))),
    ].where((e) => e.$2 <= Geo.nearbyRadiusKm).toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = _university != null
        ? Geo.universities[_university]!
        : Geo.tunisCenter;

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: _repo.listenable(),
        builder: (context, _, _) {
          final all = _repo.all().where((p) => p.available).toList();
          final listed = _listed(all);
          final shown = [for (final (p, _) in listed) p];

          return Stack(
            children: [
              FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: _university != null ? 14 : 12,
                  minZoom: 6,
                  maxZoom: 18,
                  onTap: (_, _) => setState(() => _selectedPropertyId = null),
                ),
                children: [
                  ...baseMapLayers().take(1),
                  if (_university != null)
                    CircleLayer(circles: [
                      CircleMarker(
                        point: Geo.universities[_university]!,
                        radius: Geo.nearbyRadiusKm * 1000,
                        useRadiusInMeter: true,
                        color: AppColors.rose.withValues(alpha: 0.12),
                        borderColor: AppColors.rose.withValues(alpha: 0.6),
                        borderStrokeWidth: 2,
                      ),
                    ]),
                  MarkerLayer(markers: [
                    for (final p in all)
                      Marker(
                        point: Geo.positionOf(p),
                        width: PricePin.size.width,
                        height: PricePin.size.height,
                        child: Opacity(
                          // Fade homes outside the selected campus area.
                          opacity: _university == null || shown.contains(p)
                              ? 1
                              : 0.45,
                          child: PricePin(
                            price: p.price,
                            selected: p.id == _selectedPropertyId,
                            onTap: () => shown.contains(p)
                                ? _selectProperty(p, shown)
                                : context.push('/property/${p.id}'),
                          ),
                        ),
                      ),
                  ]),
                  MarkerLayer(markers: [
                    for (final e in Geo.universities.entries)
                      Marker(
                        point: e.value,
                        width: UniversityPin.size.width,
                        height: UniversityPin.size.height,
                        alignment: Alignment.topCenter,
                        child: UniversityPin(
                          name: e.key,
                          selected: e.key == _university,
                          onTap: () => _selectUniversity(e.key),
                        ),
                      ),
                  ]),
                  ...baseMapLayers().skip(1),
                ],
              ),
              _TopBar(
                university: _university,
                onBack: () => context.pop(),
                onSelect: _selectUniversity,
                onClear: () => setState(() {
                  _university = null;
                  _selectedPropertyId = null;
                }),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24 + MediaQuery.of(context).padding.bottom,
                child: _university == null
                    ? const _Hint()
                    : listed.isEmpty
                        ? const _Hint(
                            text:
                                'Aucun logement à moins de 3 km pour le moment.')
                        : SizedBox(
                            height: 120,
                            child: PageView.builder(
                              controller: _pages,
                              itemCount: listed.length,
                              onPageChanged: (i) {
                                final p = listed[i].$1;
                                setState(() => _selectedPropertyId = p.id);
                                _map.move(Geo.positionOf(p), _map.camera.zoom);
                              },
                              itemBuilder: (_, i) => _MiniCard(
                                property: listed[i].$1,
                                distanceKm: listed[i].$2,
                                university: _university!,
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String? university;
  final VoidCallback onBack;
  final VoidCallback onClear;
  final ValueChanged<String> onSelect;

  const _TopBar({
    required this.university,
    required this.onBack,
    required this.onClear,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.plum),
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Material(
                    color: Colors.white,
                    elevation: 2,
                    shadowColor: const Color(0x33000000),
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () async {
                        final picked = await showModalBottomSheet<String>(
                          context: context,
                          showDragHandle: true,
                          backgroundColor: AppColors.cream,
                          builder: (_) => ListView(
                            shrinkWrap: true,
                            children: [
                              for (final name in Geo.universities.keys)
                                ListTile(
                                  leading: const Icon(Icons.school_outlined,
                                      color: AppColors.rose),
                                  title: Text(name),
                                  onTap: () => Navigator.pop(context, name),
                                ),
                            ],
                          ),
                        );
                        if (picked != null) onSelect(picked);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            const Icon(Icons.school_outlined,
                                color: AppColors.rose, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                university ?? 'Choisis ton université',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: university == null
                                        ? AppColors.muted
                                        : AppColors.plum),
                              ),
                            ),
                            if (university != null)
                              GestureDetector(
                                onTap: onClear,
                                child: const Icon(Icons.close,
                                    size: 20, color: AppColors.muted),
                              )
                            else
                              const Icon(Icons.expand_more,
                                  color: AppColors.muted),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(
      {this.text =
          'Touche une université 🎓 pour voir les logements autour'});

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 10),
            ],
          ),
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
}

class _MiniCard extends StatelessWidget {
  final Property property;
  final double? distanceKm;
  final String university;

  const _MiniCard({
    required this.property,
    required this.distanceKm,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x33000000),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/property/${property.id}'),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: double.infinity,
                child: PropertyCover(property: property, height: 120),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(property.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      if (distanceKm != null)
                        Text(
                          '${Geo.formatKm(distanceKm!)} de ${UniversityPin.shortName(university)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12),
                        ),
                      const SizedBox(height: 6),
                      Text('${formatPrice(property.price)} / mois',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.roseDark)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
