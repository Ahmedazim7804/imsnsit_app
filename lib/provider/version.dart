import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VersionProvider extends ChangeNotifier {
  String currentVersion = '1.0.2';
  bool needUpdate = false;

  Future<void> isLatestVersion() async {
    final response =
        await http.get(Uri.parse('https://pastebin.com/raw/zYYfMgLq'));
    String? version = response.body;

    if (version != currentVersion) {
      needUpdate = true;
    }
  }
}
