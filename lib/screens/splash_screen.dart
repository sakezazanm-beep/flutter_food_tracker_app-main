import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/food_illustration.dart';
import 'food_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const FoodHome()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.red,
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 166, height: 138, child: FoodIllustration()),
            const SizedBox(height: 17),
            const Text(
              'Food Tracker',
              style: TextStyle(
                color: Color(0xFFFFEB3B),
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text('🍔 🍟 🌭 🍿 🍨 🧁', style: TextStyle(fontSize: 21)),
            const SizedBox(height: 24),
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                color: Color(0xFFFFEB3B),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
