import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManualRelogin extends StatelessWidget {
  const ManualRelogin({super.key});

  Future<void> tryRelogin(
      BuildContext context, Ims ims, TextEditingController controller) async {
    context.loaderOverlay.show();

    String captchaText = controller.text;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username')!;
    String password = prefs.getString('password')!;

    await ims.authenticate(captchaText, username, password);

    context.loaderOverlay.hide();

    if (ims.isAuthenticated) {
      context.go('/attendance/total');
    } else {
      context.go('/authentication/manual_login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ims = context.read<ImsProvider>().ims;
    TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Captcha", style: GoogleFonts.lexend(fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                context.read<ImsProvider>().ims.logout();
                context
                    .pushReplacement('/authentication/authentication_screen');
              },
              icon: Icon(
                Icons.logout,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ))
        ],
      ),
      body: LoaderOverlay(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CaptchImage(ims: ims),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  cursorColor: Theme.of(context).colorScheme.onBackground,
                  decoration: InputDecoration(
                      labelText: 'Captcha',
                      labelStyle: GoogleFonts.lexend(
                          color: Theme.of(context).colorScheme.onBackground),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.primary.withAlpha(150),
                      isDense: true,
                      prefixIcon: const Icon(Icons.person_rounded),
                      hintText: "Fill the digits in captcha above",
                      hintStyle: GoogleFonts.lexend(
                          color: Theme.of(context).colorScheme.onBackground),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                  onPressed: () async {
                    tryRelogin(context, ims, controller);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.onBackground,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)))),
                  child: Text("Submit",
                      style: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary)))
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
            return Image.file(
              snapshot.data!,
              height: 100,
              width: 100,
              scale: 0.1,
            );
          } else {
            return const Text('Loading....');
          }
        });
  }
}
