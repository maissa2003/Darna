import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../chat/presentation/chat_inbox_screen.dart';
import '../../listings/data/property_repository.dart';
import '../../listings/models/property.dart';
import '../../listings/presentation/property_detail_screen.dart';
import '../../listings/presentation/property_form_screen.dart';
import 'auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _query = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openDetails(Property property) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final properties = PropertyRepository.getAll(query: _query);
    final ownerListings = user == null
        ? <Property>[]
        : PropertyRepository.forOwner(user.id);
    final isOwner = user?.role == 'owner';
    final pages = <Widget>[
      _ExploreView(
        userName: user?.fullName ?? 'explorateur',
        properties: properties,
        search: _search,
        onSearch: (value) => setState(() => _query = value),
        onOpen: _openDetails,
        onLogout: () => context.read<AuthProvider>().logout(),
      ),
      _MapView(properties: properties, onOpen: _openDetails),
      if (isOwner)
        _OwnerView(
          listings: ownerListings,
          onAdd: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PropertyFormScreen()),
            );
            setState(() {});
          },
          onEdit: (property) async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyFormScreen(property: property),
              ),
            );
            setState(() {});
          },
          onDelete: (property) async {
            await PropertyRepository.delete(property.id);
            setState(() {});
          },
        ),
      const ChatInboxScreen(),
    ];
    final selectedTab = _tab >= pages.length ? pages.length - 1 : _tab;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),
      body: SafeArea(
        child: IndexedStack(index: selectedTab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorer',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Carte',
          ),
          if (isOwner)
            const NavigationDestination(
              icon: Icon(Icons.home_work_outlined),
              selectedIcon: Icon(Icons.home_work),
              label: 'Mes annonces',
            ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

class _ExploreView extends StatelessWidget {
  final String userName;
  final List<Property> properties;
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final ValueChanged<Property> onOpen;
  final VoidCallback onLogout;

  const _ExploreView({
    required this.userName,
    required this.properties,
    required this.search,
    required this.onSearch,
    required this.onOpen,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final resultSliver = properties.isEmpty
        ? const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text('Aucun logement ne correspond a ta recherche.'),
              ),
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _PropertyCard(
                property: properties[index],
                onTap: () => onOpen(properties[index]),
              ),
              childCount: properties.length,
            ),
          );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${userName.split(' ').first}',
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Trouve ton chez-toi',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Compte',
                  onSelected: (value) {
                    if (value == 'logout') onLogout();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.logout),
                        title: Text('Se deconnecter'),
                      ),
                    ),
                  ],
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFD8EEE8),
                    child: Text(
                      userName.isEmpty ? 'D' : userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF0E625A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: TextField(
              controller: search,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Ville, quartier, universite...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _FilterChip(icon: Icons.location_city, label: 'Tunis'),
                _FilterChip(
                  icon: Icons.school_outlined,
                  label: 'Pres des campus',
                ),
                _FilterChip(icon: Icons.bed_outlined, label: 'Chambre'),
                _FilterChip(
                  icon: Icons.euro_rounded,
                  label: 'Moins de 800 TND',
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Des logements qui te ressemblent',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${properties.length} resultats',
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        resultSliver,
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  const _PropertyCard({required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 148,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 126,
              height: 148,
              child: Image.network(
                property.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFDDEBE7),
                  child: Icon(
                    Icons.home_work_rounded,
                    size: 34,
                    color: Color(0xFF0E7C7B),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.type.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1,
                        color: const Color(0xFF0E7C7B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 15,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          property.city,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${property.pricePerMonth.toInt()} TND / mois',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
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

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FilterChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Chip(
      avatar: Icon(icon, size: 17, color: const Color(0xFF0E7C7B)),
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class _MapView extends StatefulWidget {
  final List<Property> properties;
  final ValueChanged<Property> onOpen;
  const _MapView({required this.properties, required this.onOpen});

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  final _mapController = MapController();
  static const _tunis = LatLng(36.8065, 10.1815);
  static const _universities = [
    _UniversityPoint('ESPRIT', LatLng(36.8989177, 10.1900002)),
    _UniversityPoint('El Manar', LatLng(36.8321463, 10.1517169)),
    _UniversityPoint('Manouba', LatLng(36.8160195, 10.0617773)),
    _UniversityPoint('Tunis Business School', LatLng(36.7208565, 10.2355033)),
  ];

  void _showPropertyPreview(Property property) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      property.title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '${property.pricePerMonth.toInt()} TND',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 17,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    property.city,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                property.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.4),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onOpen(property);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Voir le logement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _tunis,
            initialZoom: 11,
            minZoom: 8,
            maxZoom: 18,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'tn.student.darna',
            ),
            MarkerLayer(
              markers: [
                for (final property in widget.properties)
                  Marker(
                    point: LatLng(property.lat, property.lng),
                    width: 64,
                    height: 30,
                    child: GestureDetector(
                      onTap: () => _showPropertyPreview(property),
                      child: _MapPricePin(
                        price: property.pricePerMonth.toInt().toString(),
                      ),
                    ),
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (final university in _universities)
                  Marker(
                    point: university.point,
                    width: 132,
                    height: 58,
                    child: _UniversityMarker(name: university.name),
                  ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        top: 18,
        left: 20,
        right: 20,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 14),
                  ],
                ),
                child: Text(
                  'Autour de Tunis',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: () => _mapController.move(_tunis, 11),
              icon: const Icon(Icons.my_location),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0E7C7B),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: 88,
        right: 20,
        child: Column(
          children: [
            IconButton.filled(
              onPressed: () => _mapController.move(
                _mapController.camera.center,
                (_mapController.camera.zoom + 1).clamp(8, 18),
              ),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0E7C7B),
              ),
            ),
            const SizedBox(height: 6),
            IconButton.filled(
              onPressed: () => _mapController.move(
                _mapController.camera.center,
                (_mapController.camera.zoom - 1).clamp(8, 18),
              ),
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0E7C7B),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        bottom: 28,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 14),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.home_work_outlined,
                color: Color(0xFF0E7C7B),
                size: 19,
              ),
              const SizedBox(width: 7),
              Text(
                '${widget.properties.length} logements',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const _NearbyLegend(
                icon: Icons.school_outlined,
                label: 'Universites',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _MapPricePin extends StatelessWidget {
  final String price;
  const _MapPricePin({required this.price});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 58,
    height: 24,
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF0E7C7B),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4)],
        ),
        child: Text(
          '$price TND',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 8,
          ),
        ),
      ),
    ),
  );
}

class _UniversityPoint {
  final String name;
  final LatLng point;

  const _UniversityPoint(this.name, this.point);
}

class _UniversityMarker extends StatelessWidget {
  final String name;

  const _UniversityMarker({required this.name});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF1E3158),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 5)],
        ),
        child: const Icon(Icons.school_rounded, size: 17, color: Colors.white),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4)],
        ),
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1E3158),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  );
}

class _NearbyLegend extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NearbyLegend({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: const Color(0xFF0E7C7B)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
    ],
  );
}

class _OwnerView extends StatelessWidget {
  final List<Property> listings;
  final VoidCallback onAdd;
  final ValueChanged<Property> onEdit;
  final ValueChanged<Property> onDelete;
  const _OwnerView({
    required this.listings,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Espace proprietaire',
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Mes annonces',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Publier'),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0E7C7B),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 14),
                Text(
                  '${listings.length} annonce(s) en ligne',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (listings.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text(
                'Publie ta premiere annonce et commence a recevoir des demandes.',
              ),
            ),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final property = listings[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  property.imageUrls.first,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                property.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${property.pricePerMonth.toInt()} TND / mois\n${property.status == 'active' ? 'Active' : 'Masquee'}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) =>
                    value == 'edit' ? onEdit(property) : onDelete(property),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                ],
              ),
            );
          }, childCount: listings.length),
        ),
    ],
  );
}
