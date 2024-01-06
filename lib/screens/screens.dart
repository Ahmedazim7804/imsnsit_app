import 'package:flutter/material.dart';
import 'package:imsnsit/screens/attandance_screen.dart';
import 'package:imsnsit/screens/authentication/manual_relogin.dart';


class Screens {

  static void goToAttandanceScreen(context) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) =>const AttandanceScreen()));
  }

  static void goToManualReloginScreen(context) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) =>const ManualRelogin()));
  }

}