import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InternetProvider extends ChangeNotifier {
  bool hasAccess = false;

  Future<bool> checkForInternet() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));

      if (response.statusCode == 200) {
        hasAccess = true;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
