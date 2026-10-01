import 'package:go_router/go_router.dart';
import '../../features/home/presentation/auth_provider.dart';
import '../../features/home/presentation/login_screen.dart';
import '../../features/home/presentation/register_screen.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';

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
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      ],
    );