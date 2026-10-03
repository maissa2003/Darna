import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPickerScreen({super.key, required this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedLocation;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  void _selectLocation(TapPosition _, LatLng point) {
    setState(() => _selectedLocation = point);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Position du logement'),
      actions: [
        IconButton(
          tooltip: 'Recentrer sur Tunis',
          onPressed: () =>
              _mapController.move(const LatLng(36.8065, 10.1815), 11),
          icon: const Icon(Icons.my_location),
        ),
      ],
    ),
    body: Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation,
            initialZoom: 14,
            minZoom: 8,
            maxZoom: 19,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: _selectLocation,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'tn.student.darna',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation,
                  width: 70,
                  height: 70,
                  child: const Icon(
                    Icons.location_pin,
                    color: Color(0xFF0E7C7B),
                    size: 52,
                  ),
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
        Positioned(
          top: 18,
          left: 18,
          right: 18,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 14),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app_outlined, color: Color(0xFF0E7C7B)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Touchez la carte pour placer le logement exactement au bon endroit.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 22,
          child: FilledButton.icon(
            onPressed: () => Navigator.pop(context, _selectedLocation),
            icon: const Icon(Icons.check),
            label: const Text('Confirmer cette position'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: const Color(0xFF0E7C7B),
            ),
          ),
        ),
      ],
    ),
  );
}
