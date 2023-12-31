import 'package:flutter/material.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/screens/authentication_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
            future: context.read<ImsProvider>().ims.getInitialData(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.done) {
                return const AuthenticationScreen();
              } else {
                return const CircularProgressIndicator();
              }
            })
    );
  }
}