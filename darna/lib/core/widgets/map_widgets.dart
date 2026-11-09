import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../theme/app_theme.dart';

/// OpenStreetMap tiles plus the attribution OSM's usage policy requires.
List<Widget> baseMapLayers() => [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'tn.student.darna',
      ),
      const SimpleAttributionWidget(
        source: Text('OpenStreetMap contributors'),
        backgroundColor: Color(0xCCFFFFFF),
      ),
    ];

class UniversityPin extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const UniversityPin({
    super.key,
    required this.name,
    required this.onTap,
    this.selected = false,
  });

  /// Marker size that fits the icon and the label below it.
  static const size = Size(130, 64);

  /// Short label so pins stay readable when zoomed out.
  static String shortName(String name) =>
      name.replaceFirst('Université de la ', '').replaceFirst('Université de ', '');

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(selected ? 9 : 7),
              decoration: BoxDecoration(
                color: selected ? AppColors.roseDark : AppColors.rose,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 6),
                ],
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(shortName(name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.roseDark)),
            ),
          ],
        ),
      );
}

/// Airbnb-style price bubble for a home.
class PricePin extends StatelessWidget {
  final int price;
  final bool selected;
  final VoidCallback? onTap;

  const PricePin(
      {super.key, required this.price, this.selected = false, this.onTap});

  static const size = Size(76, 34);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.plum : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selected ? AppColors.plum : const Color(0xFFEBD6D8)),
              boxShadow: const [
                BoxShadow(color: Color(0x2A000000), blurRadius: 6),
              ],
            ),
            child: Text('$price DT',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.plum)),
          ),
        ),
      );
}
