import 'package:flutter/material.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/screens/authentication_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MaterialApp(
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