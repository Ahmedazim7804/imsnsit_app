import 'dart:async';
import 'dart:convert';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:imsnsit/model/session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_store/cookie_store.dart';
import 'package:imsnsit/model/room.dart';

import 'parseData.dart';

class Ims {

  String? username;
  String? password;

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
  String? semester;
   
  
  Future<void> getSessionAttributes() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
  
    if (prefs.getKeys().contains('cookies') && prefs.getString('cookies') != null) {
      session.cookies = CookieStore()..updateCookies(prefs.getString('cookies')!, 'imsnsit.org', '/');
    }
    
    if (prefs.getKeys().contains('profileUrl') && prefs.getString('profileUrl') != null) {
      profileUrl = prefs.getString('profileUrl');
    }

    if (prefs.getKeys().contains('myActivitiesUrl') && prefs.getString('myActivitiesUrl') != null) {
      myActivitiesUrl = prefs.getString('myActivitiesUrl');
    }

    if (prefs.getKeys().contains('referrer') && prefs.getString('referrer') != null) {
      referrer = prefs.getString('referrer');
    }

    if (prefs.getKeys().contains('allUrls') && prefs.getString('allUrls') != null) {
      String stringAllUrls = prefs.getString('allUrls')!;
      allUrls = jsonDecode(stringAllUrls);
    }

    if (prefs.getKeys().contains('username') && prefs.getString('username') != null) {
      username = prefs.getString('username');
    }

    if (prefs.getKeys().contains('password') && prefs.getString('password') != null) {
      password = prefs.getString('password');
    }
  } 

  void store(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    for (final items in data.entries) {
      final key = items.key;
      final value = items.value;

      if (value.runtimeType != String) {
        prefs.setString(key, jsonEncode(value));
      } else {
        prefs.setString(key, value);
      }
    }
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

  Future<void> authenticate(String cap, String username, String password) async {
    
    baseHeaders.addAll(
      {
        'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Origin': 'https://www.imsnsit.org',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'frame',
      }
    );
    
    Map<String, String> data = {
            'f': '',
            'uid': username,
            'pwd': password,
            'HRAND_NUM': hrandNum!,
            'fy': '2023-24',
            'comp': 'NETAJI SUBHAS UNIVERSITY OF TECHNOLOGY',
            'cap': cap,
            'logintype': 'student',
        };

    var response = await session.post(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php'), headers: baseHeaders, data: data);
  
    if (response.body.contains('Invalid security Number')) {
      isAuthenticated = false;
      print('MAYBE WRONG CAPTCHA');
      return;
    }

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
      'username': username,
      'password': password,
      'cookies': session.getCookies(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php')),
      'profileUrl': profileUrl!,
      'myActivitiesUrl': myActivitiesUrl!,
      'referrer': referrer!,
      'allUrls': allUrls,
    });

    isAuthenticated = true;

  }

  Future<String> getCaptcha() async {
    
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
    
    return captchaImage;
  }

  Future<Map<String, String>> getProfileData() async {

    baseHeaders.addAll({
              'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php'
            });

    final response = await session.get(Uri.parse(profileUrl!), headers: baseHeaders);

    Map<String, String> profileData = ParseData.parseProfileData(response.body);
    final profileImageUrl = baseUrl.resolve(profileData['profile_image']!).toString();
    profileData['profileImage'] = profileImageUrl;
    profileData['profileUrl'] = profileUrl!;

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
    String sem = ParseData.parseSemester(response.body);
    
    semester = sem;

    return enrolledCourses;

  }

  Future<Map<String, dynamic>> getAbsoulteAttandanceData({String? rollNo, String? dept, String? degree}) async {

    Uri url = Uri.parse(allUrls['Attendance Report']!);

    http.Response response = await session.get(url, headers: baseHeaders);

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
            'sem': semester!,
            'enc_sem': encSem,
            'submit': 'Submit',
            'recentitycode': rollNo!,
            'dept': dept!,
            'degree': degree!,
            'ename': '',
            'ecode': '',
    };

    response = await session.post(url, headers: baseHeaders, data: data);
    
    final attandanceData = ParseData.parseAbsoluteAttandanceData(response.body);

    return attandanceData;
  }

  Future<Map<String, dynamic>> getAttandanceData({String? rollNo, String? dept, String? degree}) async {

    Uri url = Uri.parse(allUrls['Attendance Report']!);

    http.Response response = await session.get(url, headers: baseHeaders);
    final doc = parse(response.body);

    String encYear = doc.getElementById('enc_year')!.attributes['value']!;
    String encSem = doc.getElementById('enc_sem')!.attributes['value']!;

    if (rollNo == '' || dept == null || degree == null) {
      
      rollNo = doc.querySelector("[name=recentitycode]")!.attributes['value'];
      dept = doc.querySelector("[name=dept]")!.attributes['value'];
      degree = doc.querySelector("[name=degree]")!.attributes['value'];

    }
    

    Map<String, dynamic> courses = await getEnrolledCourses();

    Map<String, String> data = {
            'year': '2023-24',
            'enc_year': encYear,
            'sem': semester!,
            'enc_sem': encSem,
            'submit': 'Submit',
            'recentitycode': rollNo!,
            'dept': dept!,
            'degree': degree!,
            'ename': '',
            'ecode': '',
    };

    response = await session.post(url, headers: baseHeaders, data: data);
    
    final attandanceData = ParseData.parseAttandanceData(response.body, courses);

    return attandanceData;
  }

  Future<void> roomsList({required StreamController streamController}) async {
    List<Room> rooms = [];
    List<String> roomsName = [
      'APJ-01',
      'APJ-02',
      'APJ-03',
      'APJ-04',
      'APJ-05',
      'APJ-06',
      'APJ-07',
      'APJ-08',
      'APJ-09',
      'APJ-10',
      'APJ-11',
    ];

    final headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.119 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.5',
      'Accept-Encoding': 'gzip, deflate, br',
      'Referer': myActivitiesUrl!,
      'Content-Type': 'application/x-www-form-urlencoded',
      'Origin': 'https://www.imsnsit.org',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
      'Sec-Fetch-Dest': 'frame',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'same-origin',
      'Sec-Fetch-User': '?1',
      'Accept-Encoding': 'gzip',
    };

    final url = Uri.parse('https://www.imsnsit.org/imsnsit/plum_url.php?Xa9HvscdKyH6kL9nKIyCD80Af4YmbpJSlN4qzyQsnhEW752gaaBRKjC5B+5SgxUWzRm0BuyJ0EuNJ8BxklMF6Vjet5gq8CLaWdFN9qBzeu0pGzfeTxg0MznYdBq2W4O3sKNiJJKtD7BpHz30vozHgOKP0ezxpMWh2PtNzR3g6yU');

    for (String roomName in roomsName) {

      final data = {
        'roomcode': roomName,
        'room': roomName,
        'semcmb': '2-4-6-8',
        'enc_semcmb': 'P0RYCVYHDvjv4ZWnV+lsiPiOE6wbkYUVXnt1gj7ut/9uyy0d8ZkKWDvCKeeG1r0F',
        'submit': 'Go',
      };

      final res = await session.post(url, headers: headers, data: data);
      Map<String, List<String>> roomData = ParseData.parseRoomData(res.body);
      
      Room room = Room(
        name: roomName,
        mon: roomData['Mon'] ?? [],
        tue: roomData['Tue'] ?? [],
        wed: roomData['Wed'] ?? [],
        thu: roomData['Thu'] ?? [],
        fri: roomData['Fri'] ?? [],
      );

      rooms.add(room);
      streamController.sink.add(rooms);

    }
  }

  void logout() async {
    session.cookies.cookies = [];
    username = '';
    password = '';
    profileUrl = '';
    myActivitiesUrl = '';
    allUrls = {};
    isAuthenticated = false;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('cookies');
    prefs.remove('profileUrl');
    prefs.remove('myActivitiesUrl');
    prefs.remove('referrer');
    prefs.remove('allUrls');
    prefs.remove('username');
    prefs.remove('password');

  }
}

void main() {
  Ims ims = Ims();

  ims.getCaptcha();
}