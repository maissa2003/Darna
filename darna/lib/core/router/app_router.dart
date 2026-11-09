import 'package:go_router/go_router.dart';
import '../../features/home/presentation/auth_provider.dart';
import '../../features/home/presentation/login_screen.dart';
import '../../features/home/presentation/register_screen.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/listings/presentation/map_screen.dart';
import '../../features/listings/presentation/property_detail_screen.dart';
import '../../features/listings/presentation/property_form_screen.dart';
import '../../features/payments/presentation/payment_screen.dart';
import '../../features/roommates/presentation/roommate_form_screen.dart';

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
        GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/map',
          builder: (_, state) => MapScreen(
              initialUniversity: state.uri.queryParameters['university']),
        ),
        // '/property/new' must come before '/property/:id'.
        GoRoute(
            path: '/property/new',
            builder: (_, _) => const PropertyFormScreen()),
        GoRoute(
          path: '/property/:id',
          builder: (_, state) =>
              PropertyDetailScreen(propertyId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/property/:id/edit',
          builder: (_, state) =>
              PropertyFormScreen(propertyId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/pay/:bookingId',
          builder: (_, state) =>
              PaymentScreen(bookingId: state.pathParameters['bookingId']!),
        ),
        GoRoute(
            path: '/roommates/new',
            builder: (_, _) => const RoommateFormScreen()),
      ],
    );
