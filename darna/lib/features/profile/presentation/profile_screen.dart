import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../home/presentation/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    Widget info(IconData icon, String label, String? value) => ListTile(
          leading: Icon(icon),
          title: Text(label),
          subtitle:
              Text((value == null || value.isEmpty) ? 'Non renseigné' : value),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: UserAvatar(
                data: user.avatarPath, name: user.fullName, radius: 52),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(user.fullName,
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          Center(
            child: Text(user.role == 'owner' ? 'Propriétaire' : 'Étudiant'),
          ),
          const SizedBox(height: 16),
          info(Icons.email_outlined, 'Email', user.email),
          info(Icons.phone_outlined, 'Téléphone', '+216 ${user.phone}'),
          info(user.gender == 'female' ? Icons.female : Icons.male, 'Sexe',
              user.gender == 'female' ? 'Fille' : 'Garçon'),
          info(Icons.school_outlined, 'Université', user.universityId),
          info(Icons.location_city_outlined, 'Ville', user.city),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le profil'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/profile/password'),
            icon: const Icon(Icons.lock_reset),
            label: const Text('Changer le mot de passe'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}