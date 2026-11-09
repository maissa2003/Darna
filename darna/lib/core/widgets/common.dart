import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../features/listings/models/property.dart';

String formatPrice(int price) => '$price DT';
String formatDate(DateTime d) => DateFormat('d MMM yyyy', 'fr').format(d);

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

IconData propertyIcon(String type) => switch (type) {
      PropertyType.room => Icons.bed_outlined,
      PropertyType.studio => Icons.weekend_outlined,
      PropertyType.apartment => Icons.apartment_outlined,
      PropertyType.shared => Icons.groups_outlined,
      _ => Icons.home_outlined,
    };

/// Shows the first photo of a listing, or a soft gradient with an icon
/// when the owner has not added photos yet.
class PropertyCover extends StatelessWidget {
  final Property property;
  final double height;
  final int imageIndex;

  const PropertyCover({
    super.key,
    required this.property,
    this.height = 180,
    this.imageIndex = 0,
  });

  // Each listing gets a stable pastel tint so cards don't all look the same.
  static const _tints = [
    [Color(0xFFFFD6DC), Color(0xFFFFE9DF)],
    [Color(0xFFFFE0D2), Color(0xFFFFF1E6)],
    [Color(0xFFF8D4E4), Color(0xFFFFE6EE)],
    [Color(0xFFFFDCCB), Color(0xFFFCE3E8)],
  ];

  @override
  Widget build(BuildContext context) {
    if (property.images.length > imageIndex) {
      return Image.memory(
        property.images[imageIndex],
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }
    final tint = _tints[property.id.hashCode.abs() % _tints.length];
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tint,
        ),
      ),
      child: Icon(propertyIcon(property.type),
          size: height * 0.32, color: AppColors.rose.withValues(alpha: 0.55)),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 12)),
      );
}

Color statusColor(String status) => switch (status) {
      'accepted' => AppColors.success,
      'rejected' || 'cancelled' => AppColors.muted,
      _ => AppColors.warning,
    };

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                    color: AppColors.blush, shape: BoxShape.circle),
                child: Icon(icon, size: 40, color: AppColors.rose),
              ),
              const SizedBox(height: 16),
              Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted)),
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      );
}

class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const UserAvatar({super.key, required this.name, this.radius = 20});

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.blush,
        child: Text(initials(name),
            style: TextStyle(
                color: AppColors.roseDark,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.75)),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      );
}

Future<bool> confirmDialog(BuildContext context, String title, String message,
    {String confirm = 'Confirmer'}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true), child: Text(confirm)),
      ],
    ),
  );
  return result ?? false;
}

void showMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
