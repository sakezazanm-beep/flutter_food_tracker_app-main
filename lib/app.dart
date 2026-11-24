import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'screens/splash_screen.dart';

class FoodTrackerApp extends StatelessWidget {
  const FoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Food Tracker',
    debugShowCheckedModeBanner: false,
    builder: (context, child) => _MobileSystemBars(child: child ?? const SizedBox.shrink()),
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        primary: AppColors.red,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 46,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.red,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
      ),
    ),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('th')],
    home: const SplashScreen(),
  );
}

/// Chrome's mobile device emulation does not draw Android's OS bars, so add
/// them only on web. Native Android/iOS continues to use its real system UI.
class _MobileSystemBars extends StatelessWidget {
  const _MobileSystemBars({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return Column(
      children: [
        Container(
          height: 24,
          color: AppColors.red,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text(time, style: const TextStyle(color: Colors.white, fontSize: 11)),
              const SizedBox(width: 5),
              const Icon(Icons.circle, color: Colors.white, size: 4),
              const Spacer(),
              const Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 12),
              const SizedBox(width: 4),
              const Icon(Icons.wifi, color: Colors.white, size: 13),
              const SizedBox(width: 4),
              const Icon(Icons.battery_full, color: Colors.white, size: 15),
            ],
          ),
        ),
        Expanded(child: child),
        Container(
          height: 24,
          color: Colors.black,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.crop_square, color: Color(0xFFBDBDBD), size: 12),
              SizedBox(width: 30),
              Icon(Icons.circle_outlined, color: Color(0xFFBDBDBD), size: 13),
              SizedBox(width: 30),
              Icon(Icons.arrow_left, color: Color(0xFFBDBDBD), size: 17),
            ],
          ),
        ),
      ],
    );
  }
}
