import 'dart:convert';

import 'package:http_session/http_session.dart';
import 'dart:io';

class Ims {
  
  final String username = '';
  final String password = '';

  final Map<String, String> baseHeaders = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.119 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'same-origin',
        };
  
  final Uri baseUrl = Uri.parse('https://www.imsnsit.org/imsnsit/');

  String? profileUrl;
  String? myActivitiesUrl;
  List<String> allUrls = [];
  late Future<HttpSession> _session;
  bool isAuthenticated = false;
  
  Ims() {
    this._session = getSession();
  }
   
  
  Future<HttpSession> getSession() async {

    HttpSession session = HttpSession.shared;

    final file = await File('data.json');
    final fileContent = await file.readAsString();

    Map<String, dynamic> jsonContent = jsonDecode(fileContent);
  
    if (jsonContent.keys.contains('cookies')) {
      session.cookieStore.updateCookies(jsonContent['cookies'], 'imsnsit.org', '/');
    }

    if (jsonContent.containsKey('profileUrl') && jsonContent['profileUrl'] != null) {
      this.profileUrl = jsonContent['profileUrl'];
    }

    if (jsonContent.containsKey('myActivitiesUrl') && jsonContent['myActivitiesUrl'] != null) {
      this.myActivitiesUrl = jsonContent['myActivitiesUrl'];
    }

    return session;
  } 

  void store(Map<String, String> data) async {
    final file = await File('data.json');

    var fileContent = await file.readAsString();

    Map<String, dynamic> jsonData = jsonDecode(fileContent);

    jsonData.addAll(data);

    fileContent = jsonEncode(jsonData);

    file.writeAsString(fileContent);
  }

  void authenticate() async {
    _session.then((session) {

      session.get(this.baseUrl, headers: this.baseHeaders);

      getCaptcha();

    });

    
  }

  Future<(String, String)> getCaptcha() async {
    _session.then((session) async {
      final response = await session.get(Uri.parse('https://www.imsnsit.org/imsnsit/student_login110.php'), headers: baseHeaders);

      print(response.body);
    });

    return ('s', 's');
  }

}

void main() {

  final ims = Ims();
  ims.authenticate();

}