import 'package:go_router/go_router.dart';
import '../../features/home/presentation/auth_provider.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/login_screen.dart';
import '../../features/home/presentation/register_screen.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/listings/presentation/my_listings_screen.dart';
import '../../features/profile/presentation/change_password_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/roomates/presentation/roommate_screen.dart';

GoRouter createRouter(AuthProvider auth) => GoRouter(
      initialLocation: '/',
      refreshListenable: auth,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        const publicRoutes = ['/', '/login', '/register'];
        if (!auth.isLoggedIn && !publicRoutes.contains(loc)) return '/login';
        if (auth.isLoggedIn && (loc == '/login' || loc == '/register')) {
          return '/home';
        }
        if (loc == '/my-listings' && auth.user?.role != 'owner') {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(
            path: '/my-listings',
            builder: (_, _) => const MyListingsScreen()),
        GoRoute(path: '/roommates', builder: (_, _) => const RoommateScreen()),
        GoRoute(
          path: '/profile',
          builder: (_, _) => const ProfileScreen(),
          routes: [
            GoRoute(path: 'edit', builder: (_, _) => const EditProfileScreen()),
            GoRoute(
                path: 'password',
                builder: (_, _) => const ChangePasswordScreen()),
          ],
        ),
      ],
    );