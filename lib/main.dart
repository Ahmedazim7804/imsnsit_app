import 'package:flutter/material.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/screens/attandance_screen.dart';
import 'package:imsnsit/screens/authentication_screen.dart';
import 'package:imsnsit/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:imsnsit/myapp.dart';

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
    darkTheme: ThemeData.dark().copyWith(
        colorScheme: colorScheme
        ),
    home: const MyApp()
  )
    ));
}