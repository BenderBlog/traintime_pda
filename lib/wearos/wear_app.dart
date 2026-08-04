import 'package:flutter/material.dart';
import 'package:watermeter/wearos/wear_home_page.dart';
import 'package:watermeter/wearos/wear_sync_login_page.dart';

class WearApp extends StatelessWidget {
  final bool isFirst;

  const WearApp({super.key, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00A3FF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XDYou Wear',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: Colors.black,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          isDense: true,
        ),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
      ),
      home: isFirst ? const WearSyncLoginPage() : const WearHomePage(),
    );
  }
}
