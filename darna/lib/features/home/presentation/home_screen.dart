import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bookings/presentation/bookings_screen.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../listings/presentation/explore_screen.dart';
import '../../listings/presentation/my_listings_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../roommates/presentation/roommates_screen.dart';
import 'auth_provider.dart';

/// Main shell with bottom navigation. Owners get "Mes annonces" in place
/// of "Favoris".
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink(); // logging out
    final isOwner = user.role == 'owner';

    final tabs = <(Widget, NavigationDestination)>[
      (
        const ExploreScreen(),
        const NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.travel_explore),
            label: 'Explorer'),
      ),
      isOwner
          ? (
              const MyListingsScreen(),
              const NavigationDestination(
                  icon: Icon(Icons.home_work_outlined),
                  selectedIcon: Icon(Icons.home_work),
                  label: 'Annonces'),
            )
          : (
              const FavoritesScreen(),
              const NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Favoris'),
            ),
      (
        const RoommatesScreen(),
        const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Coloc'),
      ),
      (
        const BookingsScreen(),
        const NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Demandes'),
      ),
      (
        const ProfileScreen(),
        const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil'),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (final (screen, _) in tabs) screen],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [for (final (_, dest) in tabs) dest],
      ),
    );
  }
}
