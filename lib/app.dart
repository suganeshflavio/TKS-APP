import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'state/app_state.dart';

class TksApp extends StatelessWidget {
  const TksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TKS Academy',
        themeMode: ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF97316),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF6EE),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFF6EE),
            foregroundColor: Color(0xFF3A1E0B),
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
