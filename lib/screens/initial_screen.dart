import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/bloc/pre_reqs_bloc.dart';
import 'package:imsnsit/provider/mode_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imsnsit/widgets/conditional_visibilty.dart';

enum NeedToLogin { checking, no, yes, completeLogin }

enum LoggingIn {
  wait(false),
  successful(true),
  timeout(false),
  unsuccessful(false);

  const LoggingIn(this.value);
  final bool value;
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool useOfflineMode = false;

  void setOfflineMode() {
    final prefs = context.read<SharedPreferences>();

    if (prefs.containsKey('attendanceDataLastUpdated')) {
      context.read<ModeProvider>().setOffline();
      useOfflineMode = true;
    } else {}
  }

  Future<void> showTimeoutDialog() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    });
  }

  @override
  void initState() {
    context.read<ModeProvider>().reset();

    context.read<PreRequisitesBloc>().add(CheckForInternet());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: Center(
        child: BlocConsumer<PreRequisitesBloc, PreReqState>(
          listener: (context, state) {
            if (state is PreReqsAvailable) {
              if (state.needToLogin == NeedToLogin.no ||
                  state.loggingIn == LoggingIn.successful) {
                context.go('/attendance/total');
              } else if (state.needToLogin == NeedToLogin.yes) {
                context.go('/authentication/manual_login');
              } else if (state.needToLogin == NeedToLogin.completeLogin) {
                context.go('/authentication/login_screen');
              }
            }
          },
          builder: (context, state) {
            if (state is PreReqsAvailable) {
              bool? internet = state.internet;
              bool? imsWebsiteUp = state.imsWebsiteUp;
              bool? latestVersion = state.latestVersion;
              NeedToLogin? needToLogin = state.needToLogin;
              LoggingIn loggingIn = state.loggingIn;
              bool? retry = state.retry;

              if (loggingIn == LoggingIn.timeout) {
                showTimeoutDialog();
              }

              if (retry) {
                setOfflineMode();
              }

              return Column(
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
                            child: internet == null
                                ? CircularProgressIndicator(
                                    color: baseColor,
                                  )
                                : (internet
                                    ? Icon(
                                        Icons.check,
                                        color: baseColor,
                                      )
                                    : Icon(
                                        Icons.close,
                                        color: baseColor,
                                      )))
                      ],
                    ),
                  ),
                  ConditionalyVisible(
                    showIf: internet == true,
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
                            child: latestVersion == null
                                ? CircularProgressIndicator(
                                    color: baseColor,
                                  )
                                : Icon(
                                    Icons.check,
                                    color: baseColor,
                                  ))
                      ],
                    ),
                  ),
                  ConditionalyVisible(
                    showIf: latestVersion == true,
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
                            child: imsWebsiteUp == null
                                ? CircularProgressIndicator(
                                    color: baseColor,
                                  )
                                : (imsWebsiteUp
                                    ? Icon(
                                        Icons.check,
                                        color: baseColor,
                                      )
                                    : Icon(
                                        Icons.close,
                                        color: baseColor,
                                      )))
                      ],
                    ),
                  ),
                  ConditionalyVisible(
                    showIf: imsWebsiteUp == true,
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
                            child: needToLogin == null
                                ? CircularProgressIndicator(
                                    color: baseColor,
                                  )
                                : (needToLogin == NeedToLogin.no)
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
                    showIf: needToLogin == NeedToLogin.yes,
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
                                : (loggingIn.value)
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
                  retry
                      ? const SizedBox(
                          height: 16,
                        )
                      : const SizedBox.shrink(),
                  ConditionalyVisible(
                      showIf: retry,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.onBackground,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)))),
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          "Retry",
                          style: GoogleFonts.lexend(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () {
                          context.push('/initial_screen');
                        },
                      )),
                  retry
                      ? const SizedBox(
                          height: 16,
                        )
                      : const SizedBox.shrink(),
                  useOfflineMode
                      ? ConditionalyVisible(
                          showIf: retry,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.onBackground,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)))),
                            icon: const Icon(Icons
                                .signal_wifi_connected_no_internet_4_rounded),
                            label: Text(
                              "Use offline Mode",
                              style: GoogleFonts.lexend(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            onPressed: () {
                              context.read<ModeProvider>().setOffline();
                              context.push('/attendance/total');
                            },
                          ))
                      : const SizedBox.shrink(),
                ],
              );
            }

            return CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            );
          },
        ),
      ),
    );
  }
}
