part of 'pre_reqs_bloc.dart';

abstract class PreReqState {}

final class PreReqInitialState extends PreReqState {}

final class PreReqsAvailable extends PreReqState with EquatableMixin {
  PreReqsAvailable(
      {this.internet,
      this.latestVersion,
      this.imsWebsiteUp,
      this.needToLogin,
      this.retry = false,
      this.loggingIn = LoggingIn.wait});

  bool? internet;
  bool? latestVersion;
  NeedToLogin? needToLogin;
  bool? imsWebsiteUp;
  bool retry;
  LoggingIn loggingIn;

  PreReqsAvailable copyWith({
    bool? internet,
    bool? latestVersion,
    bool? imsWebsiteUp,
    NeedToLogin? needToLogin,
    LoggingIn? loggingIn,
    bool? retry,
  }) {
    return PreReqsAvailable(
        internet: internet ?? this.internet,
        latestVersion: latestVersion ?? this.latestVersion,
        imsWebsiteUp: imsWebsiteUp ?? this.imsWebsiteUp,
        needToLogin: needToLogin ?? this.needToLogin,
        loggingIn: loggingIn ?? this.loggingIn,
        retry: retry ?? this.retry);
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [internet, latestVersion, needToLogin, imsWebsiteUp, loggingIn, retry];
}
