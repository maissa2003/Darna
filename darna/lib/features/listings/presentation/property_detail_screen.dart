import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/geo.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/models/app_user.dart';
import '../../bookings/data/booking_repository.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../home/presentation/auth_provider.dart';
import '../../reviews/data/review_repository.dart';
import '../../reviews/models/review.dart';
import '../data/property_repository.dart';
import '../models/property.dart';
import 'location_map.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _properties = PropertyRepository();
  final _reviews = ReviewRepository();
  final _bookings = BookingRepository();
  final _favorites = FavoritesRepository();
  int _page = 0;

  Future<void> _delete(Property p) async {
    final ok = await confirmDialog(context, 'Supprimer l\'annonce ?',
        'Cette action est définitive. Les demandes et avis liés seront aussi supprimés.',
        confirm: 'Supprimer');
    if (!ok || !mounted) return;
    await _bookings.deleteForProperty(p.id);
    await _reviews.deleteForProperty(p.id);
    await _favorites.deleteForProperty(p.id);
    await _properties.delete(p.id);
    if (!mounted) return;
    context.pop();
    showMessage(context, 'Annonce supprimée');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    return ListenableBuilder(
      listenable: Listenable.merge([
        _properties.listenable(),
        _reviews.listenable(),
        _bookings.listenable(),
        _favorites.listenable(),
      ]),
      builder: (context, _) {
        final p = _properties.byId(widget.propertyId);
        if (p == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
                icon: Icons.home_outlined,
                title: 'Annonce introuvable',
                message: 'Cette annonce a peut-être été supprimée.'),
          );
        }
        final isOwner = p.ownerId == user.id;
        final owner = AuthRepository().userById(p.ownerId);
        final reviews = _reviews.forProperty(p.id);
        final (avg, count) = _reviews.summary(p.id);
        final isFav = _favorites.isFavorite(user.id, p.id);
        final canSeePhone = isOwner || _bookings.hasAccepted(user.id, p.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.cream,
                leading: _CircleButton(
                    icon: Icons.arrow_back, onTap: () => context.pop()),
                actions: [
                  if (!isOwner)
                    _CircleButton(
                      icon: isFav ? Icons.favorite : Icons.favorite_border,
                      onTap: () => _favorites.toggle(user.id, p.id),
                    ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (p.images.isEmpty)
                        PropertyCover(property: p, height: 320)
                      else
                        PageView.builder(
                          itemCount: p.images.length,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (_, i) => PropertyCover(
                              property: p, height: 320, imageIndex: i),
                        ),
                      if (p.images.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < p.images.length; i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  width: i == _page ? 18 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                        alpha: i == _page ? 1 : 0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverList.list(
                  children: [
                    if (!p.available)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: StatusChip(
                            label: 'Actuellement indisponible',
                            color: AppColors.muted),
                      ),
                    Text(p.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 18, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text('${p.address}, ${p.city}',
                              style: const TextStyle(color: AppColors.muted)),
                        ),
                        if (count > 0) ...[
                          const Icon(Icons.star_rounded,
                              color: AppColors.warning, size: 20),
                          Text(' ${avg.toStringAsFixed(1)} ($count)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                    if (p.university.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.school_outlined,
                              size: 18, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('Proche de ${p.university}',
                                style:
                                    const TextStyle(color: AppColors.muted)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoTile(
                            icon: propertyIcon(p.type),
                            text: PropertyType.label(p.type)),
                        _InfoTile(
                            icon: Icons.meeting_room_outlined,
                            text: '${p.rooms} pièce${p.rooms > 1 ? 's' : ''}'),
                        _InfoTile(
                            icon: Icons.chair_outlined,
                            text: p.furnished ? 'Meublé' : 'Non meublé'),
                        _InfoTile(
                            icon: Icons.wc_outlined,
                            text: GenderPolicy.label(p.genderPolicy)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionTitle('Description'),
                    Text(
                      p.description.isEmpty
                          ? 'Pas de description.'
                          : p.description,
                      style: const TextStyle(height: 1.5),
                    ),
                    if (p.amenities.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const SectionTitle('Équipements'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final a in p.amenities)
                            Chip(
                              avatar: const Icon(Icons.check_circle,
                                  size: 18, color: AppColors.success),
                              label: Text(a),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    const SectionTitle('Emplacement'),
                    _LocationSection(property: p),
                    const SizedBox(height: 24),
                    const SectionTitle('Propriétaire'),
                    _OwnerCard(owner: owner, showPhone: canSeePhone),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SectionTitle(
                              'Avis${count > 0 ? ' ($count)' : ''}'),
                        ),
                        if (!isOwner && user.role == 'student')
                          TextButton.icon(
                            onPressed: () => _showReviewSheet(p, user),
                            icon: const Icon(Icons.rate_review_outlined),
                            label: const Text('Laisser un avis'),
                          ),
                      ],
                    ),
                    if (reviews.isEmpty)
                      const Text('Aucun avis pour le moment.',
                          style: TextStyle(color: AppColors.muted))
                    else
                      for (final r in reviews) _ReviewTile(review: r),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _BottomBar(
            property: p,
            isOwner: isOwner,
            hasPending: _bookings.hasPending(user.id, p.id),
            isStudent: user.role == 'student',
            onBook: () => _showBookingSheet(p, user),
            onEdit: () => context.push('/property/${p.id}/edit'),
            onDelete: () => _delete(p),
          ),
        );
      },
    );
  }

  Future<void> _showBookingSheet(Property p, AppUser user) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.cream,
      builder: (_) => _BookingSheet(property: p, student: user),
    );
    if (sent == true && mounted) {
      showMessage(context, 'Demande envoyée au propriétaire 💌');
    }
  }

  Future<void> _showReviewSheet(Property p, AppUser user) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.cream,
      builder: (_) => _ReviewSheet(property: p, user: user),
    );
    if (sent == true && mounted) showMessage(context, 'Merci pour ton avis !');
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: IconButton.filled(
          style: IconButton.styleFrom(
              backgroundColor: Colors.white, foregroundColor: AppColors.plum),
          onPressed: onTap,
          icon: Icon(icon,
              color: icon == Icons.favorite ? AppColors.rose : null),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.peachLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.roseDark),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _OwnerCard extends StatelessWidget {
  final AppUser? owner;
  final bool showPhone;
  const _OwnerCard({required this.owner, required this.showPhone});

  @override
  Widget build(BuildContext context) {
    final name = owner?.fullName ?? 'Propriétaire';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            UserAvatar(name: name, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified,
                          size: 16, color: AppColors.rose),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    showPhone && owner != null
                        ? '📞 +216 ${owner!.phone}'
                        : 'Numéro visible après acceptation de ta demande',
                    style: TextStyle(
                        color: showPhone ? AppColors.plum : AppColors.muted,
                        fontSize: 13),
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

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(name: review.userName, radius: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.userName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(formatDate(review.createdAt),
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    for (var i = 1; i <= 5; i++)
                      Icon(
                          i <= review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: AppColors.warning),
                  ],
                ),
                if (review.comment.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(review.comment),
                ],
              ],
            ),
          ),
        ),
      );
}

class _BottomBar extends StatelessWidget {
  final Property property;
  final bool isOwner;
  final bool isStudent;
  final bool hasPending;
  final VoidCallback onBook;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BottomBar({
    required this.property,
    required this.isOwner,
    required this.isStudent,
    required this.hasPending,
    required this.onBook,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Widget action;
    if (isOwner) {
      action = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            tooltip: 'Supprimer',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Modifier'),
          ),
        ],
      );
    } else if (!isStudent) {
      action = const SizedBox.shrink();
    } else {
      action = FilledButton(
        onPressed: property.available && !hasPending ? onBook : null,
        child: Text(hasPending ? 'Demande envoyée' : 'Réserver / Visiter'),
      );
    }
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3E1E2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                  text: formatPrice(property.price),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.roseDark)),
              const TextSpan(
                  text: '\n/ mois', style: TextStyle(color: AppColors.muted)),
            ])),
          ),
          action,
        ],
      ),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  final Property property;
  final AppUser student;
  const _BookingSheet({required this.property, required this.student});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  String _kind = 'visit';
  DateTime _date = DateTime.now().add(const Duration(days: 2));
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    await BookingRepository().create(
      propertyId: widget.property.id,
      studentId: widget.student.id,
      ownerId: widget.property.ownerId,
      kind: _kind,
      date: _date,
      message: _message.text,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Contacter le propriétaire',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'visit',
                  label: Text('Visite'),
                  icon: Icon(Icons.visibility_outlined)),
              ButtonSegment(
                  value: 'reservation',
                  label: Text('Réservation'),
                  icon: Icon(Icons.event_available_outlined)),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFEBD6D8))),
            tileColor: Colors.white,
            leading: const Icon(Icons.calendar_today_outlined,
                color: AppColors.rose),
            title: Text(_kind == 'visit'
                ? 'Date de visite souhaitée'
                : 'Date d\'emménagement'),
            subtitle: Text(formatDate(_date)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _message,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'Présente-toi en quelques mots (études, durée du séjour…)',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _sending ? null : _send,
            child: const Text('Envoyer la demande'),
          ),
        ],
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  final Property property;
  final AppUser user;
  const _ReviewSheet({required this.property, required this.user});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 5;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ReviewRepository().save(Review(
      id: const Uuid().v4(),
      propertyId: widget.property.id,
      userId: widget.user.id,
      userName: widget.user.fullName,
      rating: _rating,
      comment: _comment.text.trim(),
      createdAt: DateTime.now(),
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ton avis',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  iconSize: 40,
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.warning,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comment,
            maxLines: 3,
            decoration:
                const InputDecoration(hintText: 'Raconte ton expérience…'),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Publier')),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  final Property property;
  const _LocationSection({required this.property});

  @override
  Widget build(BuildContext context) {
    final point = Geo.positionOf(property);
    final nearest = Geo.nearestUniversity(point);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push(nearest == null
              ? '/map'
              : Uri(path: '/map', queryParameters: {'university': nearest.$1})
                  .toString()),
          child: LocationMap(point: point, height: 180),
        ),
        if (nearest != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.directions_walk,
                  size: 18, color: AppColors.rose),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    '${Geo.formatKm(nearest.$2)} de ${nearest.$1}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
