import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final loggedIn = context.read<AuthProvider>().isLoggedIn;
      context.go(loggedIn ? '/home' : '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: color.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_rounded, size: 80, color: color.onPrimary),
            const SizedBox(height: 12),
            Text('Darna',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color.onPrimary)),
            const SizedBox(height: 4),
            Text('Ton logement étudiant en Tunisie',
                style: TextStyle(color: color.onPrimary)),
          ],
        ),
      ),
    );
  }
}