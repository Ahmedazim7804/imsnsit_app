part of 'pre_reqs_bloc.dart';

sealed class PreReqsEvent {}

final class CheckForInternet extends PreReqsEvent {}

final class CheckForUpdate extends PreReqsEvent {
  CheckForUpdate({required this.currentVersion});

  final String currentVersion;
}

final class CheckForImsWebsite extends PreReqsEvent {}

final class CheckForLoginState extends PreReqsEvent {}

final class TryToLogin extends PreReqsEvent {}
