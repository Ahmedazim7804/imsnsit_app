import 'package:flutter/material.dart';

class ModeProvider extends ChangeNotifier {
  bool offline = false;

  void setOffline() {
    offline = true;
  }

  void setOnline() {
    offline = false;
  }

  void reset() {
    offline = true;
  }
}
