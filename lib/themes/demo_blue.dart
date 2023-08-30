import 'package:flutter/material.dart';

var demo_blue = ThemeData(
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
