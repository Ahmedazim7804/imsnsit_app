import 'dart:convert';
import 'dart:typed_data';
import 'package:html/dom.dart';
import 'package:http_session/http_session.dart';
import 'package:html/parser.dart';
import 'package:imsnsit/model/session.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:io';

import 'parseData.dart';

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
  String? referrer;
  Map<String, dynamic> allUrls = {};
  final Session session = Session();
  bool isAuthenticated = false;
  String? hrandNum;
   
  
  Future<void> getSessionAttributes() async {

    final fileContent = await rootBundle.loadString('assets/data.json');

    Map<String, dynamic> jsonContent = jsonDecode(fileContent);
  
    if (jsonContent.keys.contains('cookies')) {
      session.cookies = CookieStore()..updateCookies(jsonContent['cookies'], 'imsnsit.org', '/');
    }
    
    if (jsonContent.containsKey('profileUrl') && jsonContent['profileUrl'] != null) {
      profileUrl = jsonContent['profileUrl'];
    }

    if (jsonContent.containsKey('myActivitiesUrl') && jsonContent['myActivitiesUrl'] != null) {
      myActivitiesUrl = jsonContent['myActivitiesUrl'];
    }

    if (jsonContent.containsKey('referrer') && jsonContent['referrer'] != null) {
      referrer = jsonContent['referrer'];
    }

    if (jsonContent.containsKey('allUrls') && jsonContent['allUrls'] != null) {
      allUrls = jsonContent['allUrls'];
    }
  } 

  void store(Map<String, dynamic> data) async {
    final file = File('data.json');

    var fileContent = await file.readAsString();

    Map<String, dynamic> jsonData = jsonDecode(fileContent);

    jsonData.addAll(data);

    fileContent = jsonEncode(jsonData);

    file.writeAsString(fileContent);
  }

  Future<bool> isUserAuthenticated() async {
    
      try {
        baseHeaders.addAll(
            {
              'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php'
            }
          );
        final response = await session.get(Uri.parse(profileUrl!), headers: baseHeaders);
        
        if (response.body.contains('Session expired')) {
          return false;
        }
      } catch (e) {
        return false;
      }

    return true;
  }

  Future<void> getInitialData() async {
    await getSessionAttributes();

    await session.get(baseUrl, headers: baseHeaders);
    
  }

  Future<void> authenticate(String cap) async {

    if (await isUserAuthenticated()) {
      isAuthenticated = true;
      return;
    }

    baseHeaders.addAll(
      {
        'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Origin': 'https://www.imsnsit.org',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'frame',
      }
    );

    final cap = stdin.readLineSync();
    
    Map<String, String> data = {
            'f': '',
            'uid': '***REMOVED***',
            'pwd': '***REMOVED***',
            'HRAND_NUM': hrandNum!,
            'fy': '2023-24',
            'comp': 'NETAJI SUBHAS UNIVERSITY OF TECHNOLOGY',
            'cap': cap!,
            'logintype': 'student',
        };

    var response = await session.post(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php'), headers: baseHeaders, data: data);
    
    referrer = response.request!.url.toString();

    final doc = parse(response.body);
    final List links = doc.getElementsByTagName('a');
    for (Element link in links) {
      if (link.text == 'Profile') {
        profileUrl = link.attributes['href'];
      }
      if (link.text == 'My Activities') {
        myActivitiesUrl = link.attributes['href'];
      }
    }

    await getAllUrls();

    store({
      'cookies': session.getCookies(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php')),
      'profileUrl': profileUrl!,
      'myActivitiesUrl': myActivitiesUrl!,
      'referrer': referrer!,
      'allUrls': allUrls,
    });

    isAuthenticated = true;

  }

  Future<Uint8List> getCaptcha() async {
    await getInitialData();
    
    baseHeaders.addAll({
          'Referer': 'https://www.imsnsit.org/imsnsit/',
          'Sec-Fetch-User': '?1'
          });
    
    var response = await session.get(Uri.parse('https://www.imsnsit.org/imsnsit/student_login110.php'), headers: baseHeaders);
    response = await session.get(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php'), headers: baseHeaders);

    final doc = parse(response.body);
    
    String? captchaImage = doc.getElementById('captchaimg')!.attributes['src'];
    captchaImage = Uri.parse(baseUrl.toString()).resolve(captchaImage!).toString();
    String? hrand = doc.getElementById('HRAND_NUM')!.attributes['value'];

    hrandNum = hrand;
    
    response = await session.get(Uri.parse(captchaImage), headers: baseHeaders);

    return response.bodyBytes;
  }

  Future<Map<String, String>> getProfileData() async {

    baseHeaders.addAll({
              'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php'
            });

    final response = await session.get(Uri.parse(profileUrl!), headers: baseHeaders);

    final profileData = ParseData.parseProfileData(response.body);

    return profileData;
  }

  Future<void> getAllUrls() async {

    final response = await session.get(Uri.parse(myActivitiesUrl!), headers: baseHeaders);

    final doc = parse(response.body);

    final uncleanUrls = doc.getElementsByTagName('a');
  
    for (var url in uncleanUrls) {
      String? link = url.attributes['href'];
      if (link != '#' && link != null) {

        String key = url.text;

        // Removes all non-alphanumeric chars and convert to camelCase.
        allUrls[key] = link;
      }
    }
  } 

  Future<Map<String, dynamic>> getEnrolledCourses() async {
    
    Uri url = Uri.parse(allUrls['Current Semester Registered Courses.']!);

    final response = await session.get(url, headers: baseHeaders);
    
    Map<String, dynamic> enrolledCourses = ParseData.parseEnrolledCoursesData(response.body);

    return enrolledCourses;

  }

  Future<Map<String, dynamic>> getAttandanceData({String? rollNo, String? dept, String? degree}) async {

    Uri url = Uri.parse(allUrls['Attendance Report']!);

    Response response = await session.get(url, headers: baseHeaders);

    final doc = parse(response.body);

    String encYear = doc.getElementById('enc_year')!.attributes['value']!;
    String encSem = doc.getElementById('enc_sem')!.attributes['value']!;

    if (rollNo == '' || dept == null || degree == null) {
      
      rollNo = doc.querySelector("[name=recentitycode]")!.attributes['value'];
      dept = doc.querySelector("[name=dept]")!.attributes['value'];
      degree = doc.querySelector("[name=degree]")!.attributes['value'];

    }

    Map<String, String> data = {
            'year': '2023-24',
            'enc_year': encYear,
            'sem': '1',
            'enc_sem': encSem,
            'submit': 'Submit',
            'recentitycode': rollNo!,
            'dept': dept!,
            'degree': degree!,
            'ename': '',
            'ecode': '',
    };

    response = await session.post(url, headers: baseHeaders, data: data);
    
    final attandanceData = ParseData.parseAttandanceData(response.body);

    return attandanceData;
  }

}

void main() {
  Ims ims = Ims();

  ims.getCaptcha();
}