import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../home/presentation/auth_provider.dart';
import '../../reviews/data/review_repository.dart';
import '../models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final favorites = FavoritesRepository();
    final (rating, count) = ReviewRepository().summary(property.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/property/${property.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PropertyCover(property: property),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _Badge(
                      icon: propertyIcon(property.type),
                      text: PropertyType.label(property.type)),
                ),
                if (user.id != property.ownerId)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: ValueListenableBuilder(
                      valueListenable: favorites.listenable(),
                      builder: (context, _, _) {
                        final fav = favorites.isFavorite(user.id, property.id);
                        return IconButton.filled(
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.white),
                          tooltip: fav
                              ? 'Retirer des favoris'
                              : 'Ajouter aux favoris',
                          onPressed: () =>
                              favorites.toggle(user.id, property.id),
                          icon: Icon(
                              fav ? Icons.favorite : Icons.favorite_border,
                              color: AppColors.rose),
                        );
                      },
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      if (count > 0) ...[
                        const Icon(Icons.star_rounded,
                            size: 18, color: AppColors.warning),
                        Text(' ${rating.toStringAsFixed(1)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 16, color: AppColors.muted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text('${property.address}, ${property.city}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.muted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: formatPrice(property.price),
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.roseDark)),
                        const TextSpan(
                            text: ' / mois',
                            style: TextStyle(color: AppColors.muted)),
                      ])),
                      const Spacer(),
                      if (property.genderPolicy != GenderPolicy.any)
                        StatusChip(
                            label: property.genderPolicy == GenderPolicy.female
                                ? 'Filles'
                                : 'Garçons',
                            color: AppColors.peach),
                      if (!property.available)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: StatusChip(
                              label: 'Indisponible', color: AppColors.muted),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Badge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.roseDark),
            const SizedBox(width: 4),
            Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.plum)),
          ],
        ),
      );
}
