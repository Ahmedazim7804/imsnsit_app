import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:imsnsit/provider/intenet_availability.dart';
import 'package:imsnsit/screens/initial_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'pre_reqs_states.dart';
part 'pre_reqs_event.dart';

class PreRequisitesBloc extends Bloc<PreReqsEvent, PreReqState> {
  PreRequisitesBloc(
      {required this.currentVersion,
      required this.ims,
      required this.sharedPreferences})
      : super(PreReqsAvailable()) {
    on<CheckForInternet>(checkForInternet);
    on<CheckForUpdate>(checkForUpdate);
    on<CheckForImsWebsite>(checkForImsWebsite);
    on<CheckForLoginState>(checkForLoginState);
    on<TryToLogin>(tryToLogin);

    add(CheckForInternet());
  }

  final String currentVersion;
  final Ims ims;
  final SharedPreferences sharedPreferences;

  void checkForInternet(
      CheckForInternet event, Emitter<PreReqState> emitter) async {
    emitter(PreReqsAvailable());
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        emitter(PreReqsAvailable(internet: true));
        add(CheckForUpdate(currentVersion: currentVersion));
      } else {
        emitter(PreReqsAvailable(internet: false, retry: true));
      }
    } catch (e) {
      emitter(PreReqsAvailable(internet: false, retry: true));
    }
  }

  void checkForUpdate(
      CheckForUpdate event, Emitter<PreReqState> emitter) async {
    String currentVersion = event.currentVersion;

    PreReqsAvailable currentState = (state as PreReqsAvailable);

    final response =
        await http.get(Uri.parse('https://pastebin.com/raw/zYYfMgLq'));
    String? version = response.body;

    if (version == currentVersion) {
      emitter(currentState.copyWith(latestVersion: true));
    } else {
      emitter(currentState.copyWith(latestVersion: false));
    }

    add(CheckForImsWebsite());
  }

  void checkForImsWebsite(
      CheckForImsWebsite event, Emitter<PreReqState> emitter) async {
    PreReqsAvailable currentState = (state as PreReqsAvailable);
    bool isImsUp = (await ims.isImsUp()).value;

    if (isImsUp) {
      emitter(currentState.copyWith(imsWebsiteUp: true));
      add(CheckForLoginState());
    } else {
      emitter(currentState.copyWith(imsWebsiteUp: false, retry: true));
    }
  }

  void checkForLoginState(
      CheckForLoginState event, Emitter<PreReqState> emitter) async {
    PreReqsAvailable currentState = (state as PreReqsAvailable);

    if (ims.username != null && ims.password != null) {
      final isUserLoggedIn = await ims.isUserAuthenticated();

      if (isUserLoggedIn) {
        emitter(currentState.copyWith(needToLogin: NeedToLogin.no));
        return;
      }

      emitter(currentState.copyWith(needToLogin: NeedToLogin.yes));
      add(TryToLogin());
    } else {
      emitter(currentState.copyWith(needToLogin: NeedToLogin.completeLogin));
    }
  }

  void tryToLogin(TryToLogin event, Emitter<PreReqState> emitter) async {
    print("LOGGGIN IN");
    PreReqsAvailable currentState = (state as PreReqsAvailable);

    String imageUrl = await ims.getCaptcha();
    String imagePath = await Functions.downloadFile(imageUrl);

    String captchaText = await Functions.performOcr(imagePath);

    String username = sharedPreferences.getString('username')!;
    String password = sharedPreferences.getString('password')!;

    await ims.authenticate(captchaText, username, password).then((value) async {
      if (value == LoginProperties.timeout) {
        emitter(
            currentState.copyWith(loggingIn: LoggingIn.timeout, retry: true));
        return;
      } else if (value == LoginProperties.loginedSuccesfully) {
        emitter(currentState.copyWith(loggingIn: LoggingIn.successful));
        return;
      }

      if (ims.isAuthenticated) {
        emitter(currentState.copyWith(loggingIn: LoggingIn.successful));
      } else {
        emitter(currentState.copyWith(
            loggingIn: LoggingIn.unsuccessful, retry: true));
      }
    });
  }
}
