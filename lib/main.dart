import 'package:flutter/material.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';
import 'package:imsnsit/myapp.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';

ThemeData catppuccinTheme(Flavor flavor) {
  Color primaryColor = flavor.mauve;
  Color secondaryColor = flavor.pink;
  return ThemeData(
      useMaterial3: true,
      appBarTheme: AppBarTheme(
          elevation: 0,
          titleTextStyle: TextStyle(
              color: flavor.text, fontSize: 20, fontWeight: FontWeight.bold),
          backgroundColor: flavor.crust,
          foregroundColor: flavor.mantle),
      colorScheme: ColorScheme(
        background: flavor.base,
        brightness: Brightness.light,
        error: flavor.surface2,
        onBackground: flavor.text,
        onError: flavor.red,
        onPrimary: primaryColor,
        onSecondary: secondaryColor,
        onSurface: flavor.text,
        primary: flavor.crust,
        secondary: flavor.mantle,
        surface: flavor.surface0,
      ),
      textTheme: const TextTheme().apply(
        bodyColor: flavor.text,
        displayColor: primaryColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
      ));
}

ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 140, 1, 248),
    background: const Color.fromRGBO(5, 10, 48, 1),
    brightness: Brightness.dark);

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ImsProvider())
    ],
    child: MaterialApp(
    themeMode: ThemeMode.dark,
    theme: catppuccinTheme(catppuccin.mocha),
    home: const MyApp()
  )
    ));
}