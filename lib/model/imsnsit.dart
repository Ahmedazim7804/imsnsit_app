import 'dart:async';
import 'dart:convert';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/model/session.dart';
import 'package:imsnsit/provider/intenet_availability.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_store/cookie_store.dart';
import 'package:imsnsit/model/room.dart';
import 'package:imsnsit/model/teacher.dart';
import 'package:imsnsit/parsers/parseData.dart';
import 'package:imsnsit/parsers/tableParser.dart';

enum LoginProperties {
  wrongCaptcha,
  wrongPassword,
  loginedSuccesfully,
  timeout
}

enum HttpProperties { timeout, succesful, unsuccesful }

class Ims {
  String? username;
  String? password;

  final Map<String, String> baseHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.119 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
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
  String? logoutUrl;
  String? referrer;
  Map<String, dynamic> allUrls = {};
  final Session session = Session();
  bool isAuthenticated = false;
  String? hrandNum;
  String? semester;

  Future<void> getSessionAttributes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getKeys().contains('cookies') &&
        prefs.getString('cookies') != null) {
      session.cookies = CookieStore()
        ..updateCookies(prefs.getString('cookies')!, 'imsnsit.org', '/');
    }

    if (prefs.getKeys().contains('profileUrl') &&
        prefs.getString('profileUrl') != null) {
      profileUrl = prefs.getString('profileUrl');
    }

    if (prefs.getKeys().contains('myActivitiesUrl') &&
        prefs.getString('myActivitiesUrl') != null) {
      myActivitiesUrl = prefs.getString('myActivitiesUrl');
    }

    if (prefs.getKeys().contains('logoutUrl') &&
        prefs.getString('logoutUrl') != null) {
      logoutUrl = prefs.getString('logoutUrl');
    }

    if (prefs.getKeys().contains('referrer') &&
        prefs.getString('referrer') != null) {
      referrer = prefs.getString('referrer');
    }

    if (prefs.getKeys().contains('allUrls') &&
        prefs.getString('allUrls') != null) {
      String stringAllUrls = prefs.getString('allUrls')!;
      allUrls = jsonDecode(stringAllUrls);
    }

    if (prefs.getKeys().contains('username') &&
        prefs.getString('username') != null) {
      username = prefs.getString('username');
    }

    if (prefs.getKeys().contains('password') &&
        prefs.getString('password') != null) {
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
          {'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php'});

      final response =
          await session.get(Uri.parse(profileUrl!), headers: baseHeaders);
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

    // await session.get(baseUrl, headers: baseHeaders);
  }

  Future<HttpResult> isImsUp() async {
    try {
      final res = await session
          .get(baseUrl, headers: baseHeaders)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        return HttpResult.successful;
      } else {
        return HttpResult.unsuccesful;
      }
    } catch (e) {
      return HttpResult.timeout;
    }
  }

  Future<LoginProperties> authenticate(
      String cap, String username, String password) async {
    baseHeaders.addAll({
      'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Origin': 'https://www.imsnsit.org',
      'Upgrade-Insecure-Requests': '1',
      'Sec-Fetch-Dest': 'frame',
    });

    Map<String, String> data = {
      'f': '',
      'uid': username,
      'pwd': password,
      'HRAND_NUM': hrandNum!,
      'fy': '2024-25',
      'comp': 'NETAJI SUBHAS UNIVERSITY OF TECHNOLOGY',
      'cap': cap,
      'logintype': 'student',
    };

    try {
      var response = await session
          .post(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php'),
              headers: baseHeaders, data: data)
          .timeout(const Duration(seconds: 5));

      final doc = parse(response.body);

      final loginResults = doc
          .querySelectorAll("html body form table tbody tr td.plum_field font");

      if (loginResults.length >= 2) {
        final loginResult = loginResults[2].text;
        if (loginResult.contains('Invalid Security Number')) {
          isAuthenticated = false;
          return LoginProperties.wrongCaptcha;
        } else if (loginResult.contains('Invalid password') ||
            loginResult.contains('Your password does not match')) {
          isAuthenticated = false;
          return LoginProperties.wrongPassword;
        }
      }

      referrer = response.request!.url.toString();

      final List links = doc.getElementsByTagName('a');
      for (Element link in links) {
        if (link.text == 'My Profile') {
          profileUrl = link.attributes['href'];
        }
        if (link.text == 'My Activities') {
          myActivitiesUrl = link.attributes['href'];
        }
        if (link.text == 'Logout') {
          logoutUrl = link.attributes['href'];
        }
      }

      final methodResponse = await getAllUrls();
      if (methodResponse == HttpProperties.timeout) {
        return LoginProperties.timeout;
      }

      store({
        'username': username,
        'password': password,
        'cookies': session.getCookies(
            Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php')),
        'profileUrl': profileUrl!,
        'myActivitiesUrl': myActivitiesUrl!,
        'referrer': referrer!,
        'allUrls': allUrls,
        'logoutUrl': logoutUrl,
      });

      isAuthenticated = true;

      return LoginProperties.loginedSuccesfully;
    } on TimeoutException catch (_) {
      return LoginProperties.timeout;
    }
  }

  Future<String> getCaptcha() async {
    baseHeaders.addAll({
      'Referer': 'https://www.imsnsit.org/imsnsit/',
      'Sec-Fetch-User': '?1'
    });

    var response = await session.get(
        Uri.parse('https://www.imsnsit.org/imsnsit/student_login110.php'),
        headers: baseHeaders);
    response = await session.get(
        Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php'),
        headers: baseHeaders);

    final doc = parse(response.body);

    String? captchaImage = doc.getElementById('captchaimg')!.attributes['src'];
    captchaImage =
        Uri.parse(baseUrl.toString()).resolve(captchaImage!).toString();
    String? hrand = doc.getElementById('HRAND_NUM')!.attributes['value'];

    hrandNum = hrand;

    return captchaImage;
  }

  Future<Map<String, String>> getProfileData() async {
    baseHeaders.addAll(
        {'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php'});

    final response =
        await session.get(Uri.parse(profileUrl!), headers: baseHeaders);

    Map<String, String> profileData = ParseData.parseProfileData(response.body);

    if (profileData.keys.isEmpty) {
      return {};
    }

    final profileImageUrl =
        baseUrl.resolve(profileData['profile_image']!).toString();
    profileData['profileImage'] = profileImageUrl;
    profileData['profileUrl'] = profileUrl!;

    Functions.saveJsonToFile(jsonEncode(profileData), DataType.profile);

    return profileData;
  }

  Future<HttpProperties> getAllUrls() async {
    try {
      final response = await session
          .get(Uri.parse(myActivitiesUrl!), headers: baseHeaders)
          .timeout(const Duration(seconds: 5));

      final doc = parse(response.body);

      final uncleanUrls = doc.getElementsByTagName('a');

      for (var url in uncleanUrls) {
        String? link = url.attributes['href'];
        if (link != '#' && link != null) {
          String key = url.text;

          // implement Removes all non-alphanumeric chars and convert to camelCase.
          key = cleanUrlKey(key);
          allUrls[key] = link;
        }
      }
    } on TimeoutException catch (_) {
      return HttpProperties.timeout;
    } catch (e) {
      return HttpProperties.unsuccesful;
    }

    return HttpProperties.succesful;
  }

  Future<Map<String, dynamic>> getEnrolledCourses() async {
    Uri url = Uri.parse(allUrls['currentsemcoursesregistered']!);

    final response = await session.get(url, headers: baseHeaders);

    Map<String, dynamic> enrolledCourses =
        ParseData.parseEnrolledCoursesData(response.body);
    String sem = ParseData.parseSemester(response.body);

    semester = sem;

    return enrolledCourses;
  }

  Future<Map<String, dynamic>> getAbsoulteAttandanceData(
      {String? rollNo, String? dept, String? degree}) async {
    Uri url = Uri.parse(allUrls['myattendance']!);

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
      'year': '2024-25',
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

    Functions.saveJsonToFile(
        jsonEncode(attandanceData), DataType.absoluteAttendance);

    return attandanceData;
  }

  Future<Map<String, dynamic>> getAttandanceData(
      {String? rollNo, String? dept, String? degree}) async {
    allUrls.forEach((key, value) {
      print(key);
    });
    Uri url = Uri.parse(allUrls['myattendance']!);

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
      'year': '2024-25',
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

    final attandanceData =
        ParseData.parseAttandanceData(response.body, courses);

    Functions.saveJsonToFile(jsonEncode(attandanceData), DataType.attendance);

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
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.119 Safari/537.36',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
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

    final url = Uri.parse(
        'https://www.imsnsit.org/imsnsit/plum_url.php?Xa9HvscdKyH6kL9nKIyCD80Af4YmbpJSlN4qzyQsnhEW752gaaBRKjC5B+5SgxUWzRm0BuyJ0EuNJ8BxklMF6Vjet5gq8CLaWdFN9qBzeu0pGzfeTxg0MznYdBq2W4O3sKNiJJKtD7BpHz30vozHgOKP0ezxpMWh2PtNzR3g6yU');

    for (String roomName in roomsName) {
      final data = {
        'roomcode': roomName,
        'room': roomName,
        'semcmb': '2-4-6-8',
        'enc_semcmb':
            'P0RYCVYHDvjv4ZWnV+lsiPiOE6wbkYUVXnt1gj7ut/9uyy0d8ZkKWDvCKeeG1r0F',
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

      if (roomName == "APJ-11") {
        final dataToSave =
            jsonEncode(rooms.map((element) => element.toJson()).toList());
        Functions.saveJsonToFile(dataToSave, DataType.rooms);
      }
    }
  }

  void logout() async {
    session.get(Uri.parse(logoutUrl!), headers: baseHeaders);

    session.cookies.cookies = [];
    username = null;
    password = null;
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

    prefs.remove('attendanceDataLastUpdated');
    prefs.remove('subjectWiseAttendanceDataLastUpdated');
    prefs.remove('roomsDataLastUpdated');
    prefs.remove('profileDataLastUpdated');
  }

  Future<List<Teacher>> searchFaculty({required String searchTerm}) async {
    final List<Teacher> teacherList = [];

    final facultyPageUrl = Uri.parse(allUrls['facultytimetable']);

    var response = await session.get(facultyPageUrl, headers: baseHeaders);

    var doc = parse(response.body);

    String inputText = doc.querySelector('html body p a')!.attributes['href']!;

    RegExp regex = RegExp(r'(?<=javascript:openURL\().*?(?=,)');
    Match? match = regex.firstMatch(inputText);

    late Uri searchUrl;
    if (match != null) {
      searchUrl = baseUrl.resolve(match.group(0)!.replaceAll("\"", ""));
    } else {
      print("No match found");
      return teacherList;
    }

    final data = {
      'typ': 'fld',
      'search': searchTerm,
      'ctrl': 'eus',
      'id': '1',
      'category': '',
      'proceed': 'Search',
    };

    response = await session.post(searchUrl, headers: baseHeaders, data: data);
    doc = parse(response.body);

    for (var _teacher in doc.querySelectorAll('li')) {
      final attrs = _teacher.text.split('; ');
      String tutor = attrs[0];
      String tutorCode = attrs[1];
      String subject = attrs[2];

      Teacher teacher =
          Teacher(tutor: tutor, tutorCode: tutorCode, subject: subject);

      teacherList.add(teacher);
    }

    return teacherList;
  }

  Future<List<List<String>>> getFacultyTimeTable(
      {required String tutor,
      required String tutorCode,
      String sem = "EVEN"}) async {
    final facultyPageUrl = Uri.parse(allUrls['facultytimetable']);

    final data = {
      'tutorcode': tutorCode,
      'tutor': tutor,
      'sem': sem,
      'enc_sem': 'IY9Vr65L90+5HW2iKCN+9bd4Oc6cwrtXEw7brbYOMD4=',
      'role': '',
      'submit': 'Proceed',
    };

    final response =
        await session.post(facultyPageUrl, data: data, headers: baseHeaders);

    final table = parse(response.body).querySelector('table');

    TableParser tableParser = TableParser(
        table: table!,
        firstRowIsInfo: true,
        hasRowHeaders: true,
        hasColumnHeaders: true,
        result: Result.columnAndRowWise,
        replace: {
          '<b>': '',
          '</b>': '',
          '<br>': '\n',
          '<hr>': '\n----------------------\n',
          '&nbsp': ' ',
        });

    final tableData = tableParser.getRowsFromTable(tableParser.table);

    return tableData;
  }
}

void main() {
  Ims ims = Ims();

  ims.getCaptcha();
}
