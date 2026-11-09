import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/tunisia.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../home/presentation/auth_provider.dart';
import '../../reviews/data/review_repository.dart';
import '../data/property_repository.dart';
import '../models/property.dart';
import 'property_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _repo = PropertyRepository();
  final _search = TextEditingController();
  PropertyFilter _filter = const PropertyFilter();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _update(PropertyFilter f) => setState(() => _filter = f);

  PropertyFilter _copy({
    String? query,
    Object? city = _keep,
    Object? type = _keep,
    Object? maxPrice = _keep,
    Object? genderPolicy = _keep,
    bool? furnishedOnly,
  }) =>
      PropertyFilter(
        query: query ?? _filter.query,
        city: city == _keep ? _filter.city : city as String?,
        type: type == _keep ? _filter.type : type as String?,
        maxPrice: maxPrice == _keep ? _filter.maxPrice : maxPrice as int?,
        genderPolicy: genderPolicy == _keep
            ? _filter.genderPolicy
            : genderPolicy as String?,
        furnishedOnly: furnishedOnly ?? _filter.furnishedOnly,
      );

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<PropertyFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.cream,
      builder: (_) => _FilterSheet(initial: _filter),
    );
    if (result != null) _update(result);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final firstName = user.fullName.split(' ').first;

    return Stack(
      children: [
        SafeArea(
      child: ListenableBuilder(
        // Reviews are included so card ratings refresh after a new review.
        listenable: Listenable.merge(
            [_repo.listenable(), ReviewRepository().listenable()]),
        builder: (context, _) {
          final results = _repo.search(_filter);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour $firstName 👋',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Trouve ton chez-toi',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _search,
                              onChanged: (v) => _update(_copy(query: v)),
                              decoration: InputDecoration(
                                hintText: 'Ville, université, quartier…',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _search.text.isEmpty
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          _search.clear();
                                          _update(_copy(query: ''));
                                        },
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Badge(
                            isLabelVisible: _filter.activeCount > 0,
                            label: Text('${_filter.activeCount}'),
                            child: IconButton.filled(
                              style: IconButton.styleFrom(
                                minimumSize: const Size(54, 54),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              tooltip: 'Filtres',
                              onPressed: _openFilters,
                              icon: const Icon(Icons.tune),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    children: [
                      _cityChip('Toutes', null),
                      for (final c in Tunisia.cities) _cityChip(c, c),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    '${results.length} logement${results.length > 1 ? 's' : ''} disponible${results.length > 1 ? 's' : ''}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
              ),
              if (results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: 'Aucun logement trouvé',
                    message: 'Essaie une autre ville ou retire des filtres.',
                    action: OutlinedButton(
                      onPressed: () {
                        _search.clear();
                        _update(const PropertyFilter());
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                  sliver: SliverList.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => PropertyCard(property: results[i]),
                  ),
                ),
            ],
          );
        },
      ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Center(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.plum,
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: const StadiumBorder(),
                elevation: 4,
              ),
              onPressed: () => context.push(user.universityId == null
                  ? '/map'
                  : Uri(path: '/map', queryParameters: {
                      'university': user.universityId!
                    }).toString()),
              icon: const Icon(Icons.map_outlined, size: 20),
              label: const Text('Carte'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cityChip(String label, String? city) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter.city == city,
          showCheckmark: false,
          onSelected: (_) => _update(_copy(city: city)),
        ),
      );
}

const _keep = Object();

class _FilterSheet extends StatefulWidget {
  final PropertyFilter initial;
  const _FilterSheet({required this.initial});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const _maxBudget = 1000;
  late String? _type = widget.initial.type;
  late double _price = (widget.initial.maxPrice ?? _maxBudget).toDouble();
  late String? _gender = widget.initial.genderPolicy;
  late bool _furnished = widget.initial.furnishedOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Type de logement'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tous'),
                selected: _type == null,
                onSelected: (_) => setState(() => _type = null),
              ),
              for (final t in PropertyType.all)
                ChoiceChip(
                  label: Text(PropertyType.label(t)),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: SectionTitle('Budget maximum')),
              Text(
                _price >= _maxBudget
                    ? 'Illimité'
                    : '${_price.round()} DT',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.roseDark),
              ),
            ],
          ),
          Slider(
            value: _price,
            min: 100,
            max: _maxBudget.toDouble(),
            divisions: 18,
            onChanged: (v) => setState(() => _price = v),
          ),
          const SizedBox(height: 8),
          const SectionTitle('Je suis'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Peu importe'),
                selected: _gender == null,
                onSelected: (_) => setState(() => _gender = null),
              ),
              ChoiceChip(
                label: const Text('Une fille'),
                selected: _gender == GenderPolicy.female,
                onSelected: (_) =>
                    setState(() => _gender = GenderPolicy.female),
              ),
              ChoiceChip(
                label: const Text('Un garçon'),
                selected: _gender == GenderPolicy.male,
                onSelected: (_) => setState(() => _gender = GenderPolicy.male),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Meublé uniquement'),
            value: _furnished,
            onChanged: (v) => setState(() => _furnished = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    PropertyFilter(
                        query: widget.initial.query,
                        city: widget.initial.city),
                  ),
                  child: const Text('Effacer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    PropertyFilter(
                      query: widget.initial.query,
                      city: widget.initial.city,
                      type: _type,
                      maxPrice:
                          _price >= _maxBudget ? null : _price.round(),
                      genderPolicy: _gender,
                      furnishedOnly: _furnished,
                    ),
                  ),
                  child: const Text('Afficher les résultats'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
