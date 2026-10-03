import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/services/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/home/presentation/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  final auth = AuthProvider(AuthRepository());
  final router = createRouter(auth);
  runApp(
    ChangeNotifierProvider.value(
      value: auth,
      child: DarnaApp(router: router),
    ),
  );
}

class DarnaApp extends StatelessWidget {
  final RouterConfig<Object> router;
  const DarnaApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Darna',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      );
}