import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imsnsit/myapp.dart';
import 'package:imsnsit/screens/attandance_screen.dart';
import 'package:imsnsit/screens/authentication/authentication_screen.dart';
import 'package:imsnsit/screens/authentication/auto_relogin.dart';
import 'package:imsnsit/screens/authentication/login_screen.dart';
import 'package:imsnsit/screens/authentication/manual_relogin.dart';
import 'package:imsnsit/screens/profile_screen.dart';
import 'package:imsnsit/screens/rooms_screen.dart';

class MyAppRouter {

  static GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const MaterialPage(child: MyApp()),
      ),
      GoRoute(
        path: '/authentication/authentication_screen',
        pageBuilder: (context, state) => const MaterialPage(child: AuthenticationScreen()),
      ),
      GoRoute(
        path: '/authentication/login_screen',
        pageBuilder: (context, state) => const MaterialPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/authentication/auto_login',
        pageBuilder: (context, state) => const MaterialPage(child: AutoRelogin()),
      ),
      GoRoute(
        path: '/authentication/manual_login',
        pageBuilder: (context, state) => const MaterialPage(child: ManualRelogin()),
      ),
      GoRoute(
        path: '/attandance',
        pageBuilder: (context, state) => const MaterialPage(child: AttandanceScreen()),
      ),
      GoRoute(
        path: '/profile_screen',
        pageBuilder: (context, state) => const MaterialPage(child: ProfileScreen()),
      ),
      GoRoute(
        path: '/rooms',
        pageBuilder: (context, state) => const MaterialPage(child: RoomScreen()),
      ),

    ]
  );

}