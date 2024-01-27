import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlayData {
  const OverlayData({required this.text, required this.waiting});
  final String text;
  final bool waiting;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final overlayPortalController = OverlayPortalController();
  final overlayStream = StreamController<OverlayData>.broadcast();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late final ims = context.read<ImsProvider>().ims;

  void onSubmit() async {
    overlayPortalController.show();

    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      overlayPortalController.hide();
      showErrorDialog();
      return;
    }

    overlayStream.sink
        .add(const OverlayData(text: "Getting Captcha", waiting: true));

    String imageUrl = await ims.getCaptcha();

    overlayStream.sink
        .add(const OverlayData(text: "Downloading Captcha", waiting: true));
    String imagePath = await Functions.downloadFile(imageUrl);

    overlayStream.sink
        .add(const OverlayData(text: "Solving Captcha", waiting: true));
    String captchaText = await Functions.performOcr(imagePath);

    overlayStream.sink.add(const OverlayData(
        text: "Waiting for response from IMS", waiting: true));

    final authenticationStatus =
        await ims.authenticate(captchaText, username, password);

    if (authenticationStatus == LoginProperties.timeout) {
      overlayPortalController.hide();
      showTimeoutDialog();
    }

    if (ims.isAuthenticated) {
      overlayStream.sink
          .add(const OverlayData(text: "Logged in", waiting: false));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', username);
      prefs.setString('password', password);

      overlayPortalController.hide();
      context.go('/attendance/total');
    } else {
      if (authenticationStatus == LoginProperties.wrongPassword) {
        overlayPortalController.hide();
        showErrorDialog();
      }
    }
  }

  void showErrorDialog() {
    showDialog(context: context, builder: (context) => popup(context));
  }

  void showTimeoutDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: const Color.fromARGB(255, 169, 37, 16),
              title: Text(
                'An error has occured',
                style: GoogleFonts.roboto(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Timeout occurred when connecting to ims website, Please try again.',
                style: GoogleFonts.roboto(),
              ),
              actions: [
                TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      "Ok",
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ));
  }

  Widget popup(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 169, 37, 16),
      title: Text(
        'An error has occured',
        style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Username or password is incorrect. Try Again',
        style: GoogleFonts.roboto(),
      ),
      actions: [
        TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              "Ok",
              style: TextStyle(color: Colors.white),
            )),
      ],
    );
  }

  Widget overlayChildBuilder(BuildContext ctx) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(ctx).colorScheme.primary.withAlpha(150),
      child: Center(
        child: StreamBuilder<OverlayData>(
          stream: overlayStream.stream,
          builder: (context, AsyncSnapshot<OverlayData> snapshot) {
            if (snapshot.hasData) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.data!.text,
                    style: GoogleFonts.lexend(),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                      height: 20,
                      width: 20,
                      child: snapshot.data!.waiting
                          ? CircularProgressIndicator(
                              color: baseColor,
                            )
                          : Icon(
                              Icons.check,
                              color: baseColor,
                            ))
                ],
              );
            } else {
              return CircularProgressIndicator(
                color: baseColor,
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverlayPortal(
        controller: overlayPortalController,
        overlayChildBuilder: overlayChildBuilder,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome to",
                style: GoogleFonts.lexend(
                    fontSize: 36, fontWeight: FontWeight.bold),
              ),
              Image.asset(
                'assets/nsut.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                'Enter your credentials to log in your account',
                style: GoogleFonts.lexend(fontSize: 15),
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: usernameController,
                  cursorColor: Theme.of(context).colorScheme.onBackground,
                  decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: GoogleFonts.lexend(
                          color: Theme.of(context).colorScheme.onBackground),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.primary.withAlpha(150),
                      isDense: true,
                      prefixIcon: const Icon(Icons.person_rounded),
                      hintText: "Enter your username",
                      hintStyle: GoogleFonts.lexend(
                          color: Theme.of(context).colorScheme.onBackground),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TextField(
                  cursorColor: Theme.of(context).colorScheme.onBackground,
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.lexend(
                          color: Theme.of(context).colorScheme.onBackground),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.primary.withAlpha(150),
                      isDense: true,
                      prefixIcon: const Icon(Icons.lock_rounded),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
              ),
              ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onBackground,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
                child: Text(
                  "Submit",
                  style: GoogleFonts.lexend(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
