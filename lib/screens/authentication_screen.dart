import 'package:flutter/material.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/screens/captcha_screen.dart';
import 'package:imsnsit/screens/homescreen.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:provider/provider.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
        
    Ims ims = Provider.of<ImsProvider>(context).ims;

    return FutureBuilder(
      future: ims.isUserAuthenticated(),
      builder: (context, snaphot) {

        if (snaphot.hasData) {
          
          bool isAuthenticated = snaphot.data!;
          
          if (isAuthenticated) {
            return const HomeScreen();
          } else {
            return const CaptchaScreen();
          }

        } else {
          return const CircularProgressIndicator();
        }

      },
    );
  }
}