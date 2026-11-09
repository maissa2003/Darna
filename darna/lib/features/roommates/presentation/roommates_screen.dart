import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/tunisia.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/models/app_user.dart';
import '../../home/presentation/auth_provider.dart';
import '../data/roommate_repository.dart';
import '../models/roommate_post.dart';

class RoommatesScreen extends StatefulWidget {
  const RoommatesScreen({super.key});

  @override
  State<RoommatesScreen> createState() => _RoommatesScreenState();
}

class _RoommatesScreenState extends State<RoommatesScreen> {
  final _repo = RoommateRepository();
  String? _city;
  String? _gender;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Colocation'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Offres'),
              Tab(text: 'Recherches'),
              Tab(text: 'Mes contacts'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/roommates/new'),
          icon: const Icon(Icons.add),
          label: const Text('Annonce'),
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge(
              [_repo.postsListenable(), _repo.contactsListenable()]),
          builder: (context, _) => TabBarView(
            children: [
              _postList(user, 'offer'),
              _postList(user, 'request'),
              _ContactsTab(user: user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _postList(AppUser user, String kind) {
    final posts = _repo.posts(kind: kind, city: _city, gender: _gender);
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              FilterChip(
                label: const Text('Filles'),
                selected: _gender == 'female',
                onSelected: (on) =>
                    setState(() => _gender = on ? 'female' : null),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Garçons'),
                selected: _gender == 'male',
                onSelected: (on) =>
                    setState(() => _gender = on ? 'male' : null),
              ),
              const SizedBox(width: 8),
              for (final c in Tunisia.cities)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    showCheckmark: false,
                    selected: _city == c,
                    onSelected: (on) => setState(() => _city = on ? c : null),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: posts.isEmpty
              ? EmptyState(
                  icon: Icons.people_outline,
                  title: kind == 'offer'
                      ? 'Aucune offre pour le moment'
                      : 'Aucune recherche pour le moment',
                  message: 'Publie une annonce pour trouver ton/ta coloc idéal·e.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _PostCard(post: posts[i], currentUser: user),
                ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final RoommatePost post;
  final AppUser currentUser;
  const _PostCard({required this.post, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final author = AuthRepository().userById(post.userId);
    final name = author?.fullName ?? 'Étudiant·e';
    final mine = post.userId == currentUser.id;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          backgroundColor: AppColors.cream,
          builder: (_) => _PostDetailSheet(post: post, user: currentUser),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(name: name),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mine ? '$name (moi)' : name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${post.city} · ${formatDate(post.createdAt)}',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: post.gender == 'female' ? 'Fille' : 'Garçon',
                    color: AppColors.peach,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      size: 18, color: AppColors.roseDark),
                  const SizedBox(width: 4),
                  Text('${formatPrice(post.budget)} / mois',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.roseDark)),
                  const SizedBox(width: 12),
                  if (post.lifestyle.isNotEmpty)
                    Expanded(
                      child: Text(post.lifestyle.take(3).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostDetailSheet extends StatefulWidget {
  final RoommatePost post;
  final AppUser user;
  const _PostDetailSheet({required this.post, required this.user});

  @override
  State<_PostDetailSheet> createState() => _PostDetailSheetState();
}

class _PostDetailSheetState extends State<_PostDetailSheet> {
  final _repo = RoommateRepository();
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final mine = post.userId == widget.user.id;
    final contact = _repo.existing(widget.user.id, post.id);
    final author = AuthRepository().userById(post.userId);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusChip(
              label: post.isOffer ? 'Propose une place' : 'Cherche un logement',
              color: AppColors.rose,
            ),
            const SizedBox(height: 10),
            Text(post.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
                '${post.city}${post.university.isNotEmpty ? ' · ${post.university}' : ''}',
                style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 4),
            Text('Budget : ${formatPrice(post.budget)} / mois',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.roseDark)),
            const SizedBox(height: 14),
            Text(post.description, style: const TextStyle(height: 1.5)),
            if (post.lifestyle.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final l in post.lifestyle) Chip(label: Text(l))
                ],
              ),
            ],
            const SizedBox(height: 20),
            if (mine)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await confirmDialog(context,
                        'Supprimer l\'annonce ?', 'Elle ne sera plus visible.',
                        confirm: 'Supprimer');
                    if (!ok) return;
                    await _repo.deletePost(post.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Supprimer mon annonce'),
                ),
              )
            else if (contact != null)
              Card(
                child: ListTile(
                  leading: Icon(
                    contact.status == 'accepted'
                        ? Icons.check_circle
                        : Icons.hourglass_top,
                    color: statusColor(contact.status),
                  ),
                  title: Text(switch (contact.status) {
                    'accepted' => 'Demande acceptée 🎉',
                    'rejected' => 'Demande refusée',
                    _ => 'Demande envoyée',
                  }),
                  subtitle: contact.status == 'accepted' && author != null
                      ? Text('📞 +216 ${author.phone}')
                      : null,
                ),
              )
            else ...[
              TextField(
                controller: _message,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'Dis-lui bonjour et présente-toi…'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await _repo.sendContact(
                        post: post,
                        fromUserId: widget.user.id,
                        message: _message.text);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    showMessage(context, 'Demande de contact envoyée 💌');
                  },
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Envoyer une demande'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactsTab extends StatelessWidget {
  final AppUser user;
  const _ContactsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final repo = RoommateRepository();
    final received = repo.received(user.id);
    final sent = repo.sent(user.id);
    if (received.isEmpty && sent.isEmpty) {
      return const EmptyState(
        icon: Icons.mark_email_unread_outlined,
        title: 'Aucun contact',
        message:
            'Les demandes que tu envoies ou reçois apparaîtront ici. Le numéro est partagé après acceptation.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        if (received.isNotEmpty) ...[
          const SectionTitle('Reçues'),
          for (final c in received)
            _ContactTile(contact: c, incoming: true, repo: repo),
          const SizedBox(height: 16),
        ],
        if (sent.isNotEmpty) ...[
          const SectionTitle('Envoyées'),
          for (final c in sent)
            _ContactTile(contact: c, incoming: false, repo: repo),
        ],
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final RoommateContact contact;
  final bool incoming;
  final RoommateRepository repo;
  const _ContactTile(
      {required this.contact, required this.incoming, required this.repo});

  @override
  Widget build(BuildContext context) {
    final other = AuthRepository()
        .userById(incoming ? contact.fromUserId : contact.toUserId);
    final post = repo.postById(contact.postId);
    final name = other?.fullName ?? '—';
    final accepted = contact.status == 'accepted';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(name: name),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text(post?.title ?? 'Annonce supprimée',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: switch (contact.status) {
                      'accepted' => 'Acceptée',
                      'rejected' => 'Refusée',
                      _ => 'En attente',
                    },
                    color: statusColor(contact.status),
                  ),
                ],
              ),
              if (contact.message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('« ${contact.message} »',
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
              if (accepted && other != null) ...[
                const SizedBox(height: 8),
                Text('📞 +216 ${other.phone}',
                    style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600)),
              ],
              if (incoming && contact.status == 'pending') ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            repo.setContactStatus(contact, 'rejected'),
                        child: const Text('Refuser'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(64, 48)),
                        onPressed: () =>
                            repo.setContactStatus(contact, 'accepted'),
                        child: const Text('Accepter'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
