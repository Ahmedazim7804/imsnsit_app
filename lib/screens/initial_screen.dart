import 'package:flutter/material.dart';
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
import 'package:imsnsit/widgets/conditional_visibilty.dart';

enum NeedToLogin { checking, no, yes, completeLogin }

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
  Future<bool?> waitForUpdateDialog = Future.delayed(Duration.zero);

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
      return NeedToLogin.completeLogin;
    }
  }

  Future<void> showTimeoutDialog() async {
    await showDialog(
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

  Future<bool> autoLogin() async {
    String imageUrl = await ims.getCaptcha();
    String imagePath = await Functions.downloadFile(imageUrl);

    String captchaText = await Functions.performOcr(imagePath);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username')!;
    String password = prefs.getString('password')!;

    await ims.authenticate(captchaText, username, password).then((value) async {
      if (value == LoginProperties.timeout) {
        await showTimeoutDialog();
        return ims.isAuthenticated;
      }
    });

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
            waitForUpdateDialog = showDialog(
                barrierColor: Colors.transparent,
                context: context,
                builder: (_) => const UpdateDialog()).then((value) {
              return false;
            });
          }

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
                    waitForUpdateDialog.whenComplete(() {
                      context.go('/attandance');
                    });
                  } else {
                    setState(() {
                      loggingIn = LoggingIn.unsuccessful;
                    });
                    waitForUpdateDialog.whenComplete(() {
                      context.go('/authentication/manual_login');
                    });
                  }
                });
              } else if (userLoggedIn == NeedToLogin.completeLogin) {
                waitForUpdateDialog.whenComplete(() {
                  context.go('/authentication/login_screen');
                });
              } else {
                waitForUpdateDialog.whenComplete(() {
                  context.go('/attandance');
                });
              }
            });
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
                      "Ims Website Working",
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
