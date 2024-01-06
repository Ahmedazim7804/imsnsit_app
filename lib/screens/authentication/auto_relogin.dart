import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/screens/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

@RoutePage()
class AutoRelogin extends StatelessWidget {
  const AutoRelogin({super.key});

  Future<void> tryAutoLogin(Ims ims, BuildContext context) async {

    String imageUrl = await ims.getCaptcha();
    String imagePath = await Functions.downloadFile(imageUrl);

    String captchaText = await Functions.performOcr(imagePath);
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username')!;
    String password = prefs.getString('password')!;

    await ims.authenticate(captchaText, username, password);
    
    print(captchaText);
    
    if (ims.isAuthenticated) {
      Screens.goToAttandanceScreen(context);
    } else {
      Screens.goToManualReloginScreen(context);
    }

  }

  @override
  Widget build(BuildContext context) {

    final ims = Provider.of<ImsProvider>(context).ims;
    tryAutoLogin(ims, context);

    return const Center(child: CircularProgressIndicator());
  }
}
