import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/provider/intenet_availability.dart';
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/provider/version.dart';
import 'package:imsnsit/widgets/update_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NeedToLogin { checking, no, yes }

enum LoggingIn { wait, successful, unsuccessful }

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool internetAvailable = false;
  bool imsLoggedIn = false;
  bool imsUp = false;
  bool checkingForUpdate = false;

  NeedToLogin userLoggedIn = NeedToLogin.checking;
  LoggingIn loggingIn = LoggingIn.wait;

  late InternetProvider internetProvider = context.read<InternetProvider>();
  late VersionProvider versionProvider = context.read<VersionProvider>();
  late Ims ims = context.read<ImsProvider>().ims;

  Future<NeedToLogin> doesUserNeedToLogin() async {
    if (ims.username != null && ims.password != null) {
      final isUserLoggedIn = await ims.isUserAuthenticated();

      if (isUserLoggedIn) {
        return NeedToLogin.no;
      }
      return NeedToLogin.yes;
    } else {
      return NeedToLogin.yes;
    }
  }

  Future<bool> autoLogin() async {
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
  void initState() {
    internetProvider.checkForInternet().then((availability) {
      setState(() {
        internetAvailable = availability;
      });

      if (internetAvailable) {
        versionProvider.isLatestVersion().then((isUpdateAvailable) {
          setState(() {
            checkingForUpdate = true;
          });

          if (isUpdateAvailable) {
            showDialog(
                barrierColor: Colors.transparent,
                context: context,
                builder: (_) => const UpdateDialog());
          }
        });

        ims.isImsUp().then((isImsUp) {
          setState(() {
            imsUp = isImsUp;
          });

          doesUserNeedToLogin().then((value) {
            setState(() {
              userLoggedIn = value;
            });

            if (userLoggedIn == NeedToLogin.yes) {
              autoLogin().then((loggingInResult) {
                if (loggingInResult) {
                  setState(() {
                    loggingIn = LoggingIn.successful;
                  });
                  context.go('/attandance');
                } else {
                  setState(() {
                    loggingIn = LoggingIn.unsuccessful;
                  });
                  context.go('/manual_login');
                }
              });
            } else {
              context.go('/attandance');
            }
          });
        });
      }
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConditionalyVisible(
                showIf: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Checking for internet",
                      style: GoogleFonts.lexend(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        height: 20,
                        width: 20,
                        child: internetAvailable
                            ? Icon(
                                Icons.check,
                                color: baseColor,
                              )
                            : CircularProgressIndicator(
                                color: baseColor,
                              ))
                  ],
                ),
              ),
              ConditionalyVisible(
                showIf: internetAvailable == true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Checking for update",
                      style: GoogleFonts.lexend(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        height: 20,
                        width: 20,
                        child: checkingForUpdate
                            ? Icon(
                                Icons.check,
                                color: baseColor,
                              )
                            : CircularProgressIndicator(
                                color: baseColor,
                              ))
                  ],
                ),
              ),
              ConditionalyVisible(
                showIf: checkingForUpdate == true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ims Available",
                      style: GoogleFonts.lexend(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        height: 20,
                        width: 20,
                        child: imsUp
                            ? Icon(
                                Icons.check,
                                color: baseColor,
                              )
                            : CircularProgressIndicator(
                                color: baseColor,
                              ))
                  ],
                ),
              ),
              ConditionalyVisible(
                showIf: imsUp == true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "User is logged in",
                      style: GoogleFonts.lexend(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        height: 20,
                        width: 20,
                        child: userLoggedIn == NeedToLogin.checking
                            ? CircularProgressIndicator(
                                color: baseColor,
                              )
                            : (userLoggedIn == NeedToLogin.no)
                                ? Icon(
                                    Icons.check,
                                    color: baseColor,
                                  )
                                : Icon(
                                    Icons.close,
                                    color: baseColor,
                                  ))
                  ],
                ),
              ),
              ConditionalyVisible(
                showIf: userLoggedIn == NeedToLogin.yes,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Trying to login",
                      style: GoogleFonts.lexend(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        height: 20,
                        width: 20,
                        child: loggingIn == LoggingIn.wait
                            ? CircularProgressIndicator(
                                color: baseColor,
                              )
                            : (loggingIn == LoggingIn.successful)
                                ? Icon(
                                    Icons.check,
                                    color: baseColor,
                                  )
                                : Icon(
                                    Icons.close,
                                    color: baseColor,
                                  ))
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}

class ConditionalyVisible extends StatelessWidget {
  const ConditionalyVisible(
      {super.key, required this.child, required this.showIf});

  final Widget child;
  final bool showIf;

  @override
  Widget build(BuildContext context) {
    return showIf
        ? SizedBox(
            height: 50,
            child: child
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 500)))
        : const SizedBox.shrink();
  }
}
