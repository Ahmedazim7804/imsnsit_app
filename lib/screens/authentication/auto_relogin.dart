import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AutoRelogin extends StatelessWidget {
  const AutoRelogin({super.key});

  Future<bool> tryAutoLogin(Ims ims) async {
    String imageUrl = await ims.getCaptcha();
    String imagePath = await Functions.downloadFile(imageUrl);

    String captchaText = await Functions.performOcr(imagePath);
  
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username')!;
    String password = prefs.getString('password')!;

    await ims.authenticate(captchaText, username, password);

    return ims.isAuthenticated;

  }

  @override
  Widget build(BuildContext context) {

    final ims = Provider.of<ImsProvider>(context).ims;

    tryAutoLogin(ims).then((loggedIn) {
      if (loggedIn) {
        context.go('/rooms');
      } else {
        context.go('/authentication/manual_login');
      }
    });

    return const Center(child: CircularProgressIndicator());
  }
}
