import 'package:flutter/material.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/screens/attandance_screen.dart';
import 'package:imsnsit/screens/authentication/authentication_screen.dart';
import 'package:imsnsit/screens/profile_screen.dart';
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
                return const AttandanceScreen();
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })
    );
  }
}