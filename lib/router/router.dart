import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imsnsit/root_scaffold.dart';
import 'package:imsnsit/screens/about_screen.dart';
import 'package:imsnsit/screens/attandance_screen.dart';
import 'package:imsnsit/screens/authentication/auto_relogin.dart';
import 'package:imsnsit/screens/authentication/login_screen.dart';
import 'package:imsnsit/screens/authentication/manual_relogin.dart';
import 'package:imsnsit/screens/intial_screen.dart';
import 'package:imsnsit/screens/profile_screen.dart';
import 'package:imsnsit/screens/rooms_screen.dart';
import 'package:imsnsit/screens/subject_attendance_screen.dart';
import 'package:imsnsit/widgets/update_dialog.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');
final _shellNavigatorAttendanceKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellAttendance');
final _shellNavigatorRoomsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellRooms');

class MyAppRouter {
  static GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/initial_screen',
      routes: [
        StatefulShellRoute.indexedStack(
            builder: (context, state, child) {
              print(state.fullPath);

              return AppScaffold(
                child: child,
              );
            },
            branches: [
              StatefulShellBranch(
                  navigatorKey: _shellNavigatorAttendanceKey,
                  routes: [
                    GoRoute(
                      path: '/attandance',
                      pageBuilder: (context, state) =>
                          const MaterialPage(child: AttandanceScreen()),
                    ),
                  ]),
              StatefulShellBranch(
                  navigatorKey: _shellNavigatorRoomsKey,
                  routes: [
                    GoRoute(
                      path: '/rooms',
                      pageBuilder: (context, state) =>
                          const MaterialPage(child: RoomScreen()),
                    ),
                  ]),
              StatefulShellBranch(
                  navigatorKey: _shellNavigatorProfileKey,
                  routes: [
                    GoRoute(
                      path: '/profile_screen',
                      pageBuilder: (context, state) =>
                          const MaterialPage(child: ProfileScreen()),
                    ),
                  ])
            ]),
        GoRoute(
          path: '/authentication/login_screen',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginScreen()),
        ),
        GoRoute(
          path: '/authentication/auto_login',
          pageBuilder: (context, state) =>
              const MaterialPage(child: AutoRelogin()),
        ),
        GoRoute(
          path: '/authentication/manual_login',
          pageBuilder: (context, state) =>
              const MaterialPage(child: ManualRelogin()),
        ),
        GoRoute(
          path: '/about_screen',
          pageBuilder: (context, state) =>
              const MaterialPage(child: AboutScreen()),
        ),
        GoRoute(
          path: '/initial_screen',
          pageBuilder: (context, state) =>
              const MaterialPage(child: InitialScreen()),
        ),
        GoRoute(
          path: '/update_screen',
          pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true,
              maintainState: true,
              child: UpdateDialog()),
        ),
        GoRoute(
          name: 'subject_attendance',
          path: '/subject_attendance/:subject/:subjectCode',
          pageBuilder: (context, state) => MaterialPage(
              child: SubjectAttandanceScreen(
            subject: state.pathParameters['subject']!,
            subjectCode: state.pathParameters['subjectCode']!,
          )),
        ),
      ]);
}
