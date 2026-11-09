import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/geo.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/map_widgets.dart';

/// Small map showing a home and the universities around it. When [onTap]
/// is set (listing form), tapping the map moves the home's pin.
class LocationMap extends StatelessWidget {
  final LatLng point;
  final MapController? controller;
  final ValueChanged<LatLng>? onTap;
  final double height;

  const LocationMap({
    super.key,
    required this.point,
    this.controller,
    this.onTap,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: point,
            initialZoom: 14,
            onTap: onTap == null ? null : (_, latLng) => onTap!(latLng),
            // A read-only preview should not steal the page's scroll.
            interactionOptions: InteractionOptions(
              flags: onTap == null
                  ? InteractiveFlag.none
                  : InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            ...baseMapLayers().take(1),
            MarkerLayer(markers: [
              for (final e in Geo.universities.entries)
                if (Geo.km(e.value, point) < 5)
                  Marker(
                    point: e.value,
                    width: UniversityPin.size.width,
                    height: UniversityPin.size.height,
                    alignment: Alignment.topCenter,
                    child: UniversityPin(name: e.key, onTap: () {}),
                  ),
              Marker(
                point: point,
                width: 44,
                height: 44,
                alignment: Alignment.topCenter,
                child: const Icon(Icons.location_on,
                    size: 44, color: AppColors.plum),
              ),
            ]),
            ...baseMapLayers().skip(1),
          ],
        ),
      ),
    );
  }
}
