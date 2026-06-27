import 'package:flutter/material.dart';

import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sk_widgets.dart';
import 'home_shell.dart';
import 'login_screen.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    final onboarded = await SessionService.onboardingCompleted();
    final session = await SessionService.get();
    if (!mounted) return;
    final Widget target = !onboarded ? const OnboardingScreen() : (session == null ? const LoginScreen() : const HomeShell());
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => target));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 18),
          child: Column(
            children: [
              const Spacer(),
              const SkLogo(size: 96),
              const SizedBox(height: 18),
              const Text('Smart Khata', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -.8)),
              const SizedBox(height: 46),
              const InfoLine(icon: Icons.download_done_rounded, title: '100% Free', subtitle: 'Smart Khata App is free to download', color: Color(0xFF2F80ED)),
              const SizedBox(height: 22),
              const InfoLine(icon: Icons.verified_user_rounded, title: '100% Safe & Secure', subtitle: 'Secure app for your business', color: AppColors.green),
              const SizedBox(height: 22),
              const InfoLine(icon: Icons.cloud_done_rounded, title: 'Database Security First', subtitle: 'Database security is our first priority', color: Color(0xFFFFB43B)),
              const Spacer(),
              Text('Powered by Wabwar Software House', style: TextStyle(color: AppColors.primary.withAlpha(170), fontSize: 12.5, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
