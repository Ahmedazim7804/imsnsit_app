import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VersionProvider extends ChangeNotifier {
  String currentVersion = '1.0.0';
  bool needUpdate = true;

  Future<void> isLatestVersion() async {
    final response = await http.get(Uri.parse('https://gist.githubusercontent.com/Ahmedazim7804/6ef4d41859a1fadea8a0f563de9a90dc/raw/183cbb21dbc18f886dcba13e40fcafc56c9bbe0f/gistfile1.txt'));
    String? version = response.body;
    
    if (version != currentVersion) {
      needUpdate = true;
    }

  }
}