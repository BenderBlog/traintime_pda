import 'package:flutter/material.dart';

final demo_blue = ThemeData(
  // Define the default brightness and colors.
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(49, 78, 122, 1),
    primary: const Color.fromRGBO(49, 78, 122, 1),
    primaryContainer: const Color.fromRGBO(49, 78, 122, 1),
    onPrimaryContainer: const Color.fromRGBO(255, 255, 255, 1),
    background: const Color.fromRGBO(245, 245, 245, 1),
    secondary: const Color.fromRGBO(226, 232, 243, 1),
    secondaryContainer: const Color.fromRGBO(226, 232, 243, 1),
    onSecondaryContainer: const Color.fromRGBO(49, 78, 122, 1),
  ),

  // primaryColor: Color.fromRGBO(49, 78, 122, 1),

  // Define the default font family.
  // fontFamily: 'Georgia',

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  // textTheme: const TextTheme(
  //   displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
  //   titleLarge: TextStyle(fontSize: 36, fontStyle: FontStyle.italic),
  //   bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Hind'),
);

final demo_blue_dark = ThemeData(
  // Define the default brightness and colors.
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromRGBO(17, 40, 64, 1), // Darker base color
    primary: const Color.fromARGB(252, 250, 243, 240),
    primaryContainer: const Color.fromRGBO(17, 40, 64, 1),
    onPrimaryContainer: const Color.fromRGBO(255, 255, 255, 1),
    background: const Color.fromRGBO(20, 20, 20, 1), // Dark background
    secondary:
        const Color.fromRGBO(30, 30, 30, 1), // Slightly lighter secondary
    secondaryContainer: const Color.fromRGBO(30, 30, 30, 1),
    onSecondaryContainer: const Color.fromRGBO(255, 255, 255, 1),
  ),
);
