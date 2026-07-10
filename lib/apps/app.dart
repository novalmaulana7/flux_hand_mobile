import 'package:flutter/material.dart';
import '../router/app_router.dart';

class BlurWaveApp extends StatelessWidget {
  const BlurWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.dark(useMaterial3: true);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flux Hand',
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFF121414),
        colorScheme: baseTheme.colorScheme.copyWith(
          surface: const Color(0xFF121414),
          primary: const Color(0xFF5FFBD6),
          secondary: const Color(0xFFB9C7E4),
          onSurface: const Color(0xFFE2E2E2),
        ),
        textTheme: baseTheme.textTheme.apply(
          bodyColor: const Color(0xFFE2E2E2),
          displayColor: const Color(0xFFE2E2E2),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
