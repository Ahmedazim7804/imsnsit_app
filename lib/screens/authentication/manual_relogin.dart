import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManualRelogin extends StatelessWidget {
  const ManualRelogin({super.key});

  Future<void> tryRelogin(BuildContext context, Ims ims, TextEditingController controller) async {

    String captchaText = controller.text;
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username')!;
    String password = prefs.getString('password')!;

    await ims.authenticate(captchaText, username, password);

    if (ims.isAuthenticated) {
      context.go('/attandance');
    } else {
      context.go('/authentication/manual_login');
    }

  }

  @override
  Widget build(BuildContext context) {
    final ims = context.read<ImsProvider>().ims;
    TextEditingController controller = TextEditingController();

    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 400,
          width: 400,
          child: Column(
            children: [
              CaptchImage(ims: ims),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Captcha',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSecondary,
                    isDense: true,
                    prefixIcon: const Icon(Icons.person_rounded),
                    hintText: "Enter your username",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    )
                  ),),
              ),
              ElevatedButton(
                  onPressed: () async {
                    tryRelogin(context, ims, controller);
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))
                    ),
                  child: Text("Submit", style: GoogleFonts.habibi(fontSize: 15, fontWeight: FontWeight.w600),),)
            ],
          ),
        ),
      ),
    );
  }
}

class CaptchImage extends StatelessWidget {
  const CaptchImage({super.key, required this.ims});
  
  final Ims ims;

  Future<File> getLocalCaptchaImageFile() async {
    String filePath = await Functions.downloadFile(await ims.getCaptcha());

    return File(filePath);
  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: getLocalCaptchaImageFile(),
      builder: (context, snapshot) {

        if (snapshot.hasData) {
        
          return Image.file(snapshot.data!);
        
        } else {
          return const Text('Loading....');
        }
      
      } 
      );
  }
}