import 'dart:convert';

import 'package:http_session/http_session.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
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
  final HttpSession session = HttpSession(acceptBadCertificate: false,);
  bool isAuthenticated = false;

  Ims() {
    getSessionAttributes();
  }
   
  
  Future<HttpSession> getSessionAttributes() async {

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

    await session.get(this.baseUrl, headers: this.baseHeaders);

    var (String captchaImage, String hrandNum) = await getCaptcha();

    this.baseHeaders.addAll(
      {
        'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Origin': 'https://www.imsnsit.org',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'frame',
      }
    );

    print("Enter The Captcha $captchaImage : ");
    final cap = await stdin.readLineSync();
    
    Map data = {
            'f': '',
            'uid': '***REMOVED***',
            'pwd': '***REMOVED***',
            'HRAND_NUM': hrandNum,
            'fy': '2023-24',
            'comp': 'NETAJI SUBHAS UNIVERSITY OF TECHNOLOGY',
            'cap': cap,
            'logintype': 'student',
        };
    String cookies = session.cookieStore.cookies[0].toString();
    cookies = cookies.split(', ')[0];
    baseHeaders['Cookie'] = cookies;
    print(cookies);

    var response = await http.post(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php'), headers: baseHeaders, body: data);
    final uww = baseUrl.resolve(response.headers['location']!);
    response = await http.get(uww, headers: baseHeaders);

    print(response.body);

    
  }

  Future<(String, String)> getCaptcha() async {

    this.baseHeaders.addAll({
          'Referer': 'https://www.imsnsit.org/imsnsit/',
          'Sec-Fetch-User': '?1'
          });

    final response = await session.get(Uri.parse('https://www.imsnsit.org/imsnsit/student_login110.php'), headers: baseHeaders);
    final doc = parse(response.body);

    String? captchaImage = doc.getElementById('captchaimg')!.attributes['src'];
    captchaImage = Uri.parse(baseUrl.toString()).resolve(captchaImage!).toString();
    String? hrand = doc.getElementById('HRAND_NUM')!.attributes['value'];

    return (captchaImage, hrand!);
  }

}

void main() {

  final ims = Ims();
  ims.authenticate();

}