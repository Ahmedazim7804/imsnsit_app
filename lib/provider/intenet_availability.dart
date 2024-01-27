import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum HttpResult {
  successful(true),
  unsuccesful(false),
  waiting(false),
  timeout(false);

  final bool value;
  const HttpResult(this.value);
}

class InternetProvider extends ChangeNotifier {
  bool hasAccess = false;

  Future<HttpResult> checkForInternet() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        hasAccess = true;
        return HttpResult.successful;
      } else {
        return HttpResult.unsuccesful;
      }
    } catch (e) {
      return HttpResult.timeout;
    }
  }
}
