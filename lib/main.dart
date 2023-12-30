import 'package:flutter/material.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/screens/attandance_screen.dart';
import 'package:imsnsit/screens/authentication_screen.dart';
import 'package:provider/provider.dart';

ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 140, 1, 248),
    background: const Color.fromRGBO(5, 10, 48, 1),
    brightness: Brightness.dark);

void main() {
  runApp(MaterialApp(
    themeMode: ThemeMode.dark,
    darkTheme: ThemeData.dark().copyWith(
        colorScheme: colorScheme
        ),
    home: Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => ImsProvider(),
        child: Consumer<ImsProvider>(builder: (context, ImsProvider, child) {

          return FutureBuilder(
            future: ImsProvider.ims.getInitialData(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.done) {
                return const AuthenticationScreen();
              } else {
                return const CircularProgressIndicator();
              }
            });

        }),
      ),
    ),
  ));
}