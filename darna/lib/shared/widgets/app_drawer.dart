import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/home/presentation/auth_provider.dart';
import 'user_avatar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();
    final isOwner = user.role == 'owner';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture:
                  UserAvatar(data: user.avatarPath, name: user.fullName),
              accountName: Text(user.fullName),
              accountEmail: Text(
                  '${user.email} • ${isOwner ? 'Propriétaire' : 'Étudiant'}'),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home');
              },
            ),
            if (isOwner)
              ListTile(
                leading: const Icon(Icons.apartment_outlined),
                title: const Text('Mes publications'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/my-listings');
                },
              ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Mon profil'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () => context.read<AuthProvider>().logout(),
            ),
          ],
        ),
      ),
    );
  }
}