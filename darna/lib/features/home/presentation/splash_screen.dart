import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
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
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final loggedIn = context.read<AuthProvider>().isLoggedIn;
      context.go(loggedIn ? '/home' : '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(
                  offset: Offset(0, 20 * (1 - t)), child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(Icons.home_rounded,
                      size: 64, color: AppColors.rose),
                ),
                const SizedBox(height: 20),
                const Text('Darna',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text('Ton chez-toi, loin de chez toi',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.95))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
