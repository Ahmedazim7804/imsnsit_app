import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VersionProvider extends ChangeNotifier {
  String currentVersion = '1.0.0';
  bool needUpdate = false;

  Future<void> isLatestVersion() async {
    final response = await http.get(Uri.parse('https://gist.githubusercontent.com/Ahmedazim7804/6ef4d41859a1fadea8a0f563de9a90dc/raw/001fda9648ca4ec50adeaf4bdfeb3ef5162e6441/imsnsit_app_version.txt'));
    String? version = response.body;
    
    if (version != currentVersion) {
      needUpdate = true;
    }

  }
}