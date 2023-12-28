import 'dart:convert';
import 'package:cookie_store/cookie_store.dart';
import 'package:html/dom.dart';
import 'package:http_session/http_session.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class Session {
  final client = http.Client();
  CookieStore cookies = CookieStore();

  int maxRedirects;

  Session({this.maxRedirects = 15}) {
  }


  Future<Response> get(Uri url, {int redirectsLeft=15, Map<String, String> headers=const {}}) async {
    if (--redirectsLeft < 0) {
      throw Exception('Too many Redirects');
    }

    headers['Cookie'] = getCookies(url);
    
    final response = await http.get(url, headers: headers);

    updateCookies(response.headers, url);

    if (response.headers.containsKey('location')) {
      String? location = response.headers['location'];
      headers['location'] = '';
      if (location != null) {
        final redirectUri = url.resolve(location);
        
        return get(redirectUri, redirectsLeft: redirectsLeft-1, headers: headers);
      }
    }

    return response;
  }

  Future<Response> post(Uri url, {int redirectsLeft=15, Map<String, String> headers=const {}, Map<String, String> data = const{}}) async {
    if (--redirectsLeft < 0) {
      throw Exception('Too many Redirects');
    }

    headers['Cookie'] = getCookies(url);

    final response = await http.post(url, headers: headers, body: data);

    updateCookies(response.headers, url);

    if (response.headers.containsKey('location')) {
      String? location = response.headers['location'];
      headers['location'] = '';
      if (location != null) {
        final redirectUri = url.resolve(location);
        
        return get(redirectUri, redirectsLeft: redirectsLeft-1, headers: headers);
      }
    }
    
    return response;
  }

  String getCookies(Uri url) {
    String cookieHeader = CookieStore.buildCookieHeader(cookies.getCookiesForRequest(url.host, url.path));
    return cookieHeader;
  }

  void updateCookies(Map<String, String> headers, Uri url) {
    String? rawCookies = headers['set-cookie'];
    if (rawCookies != null) {
      cookies.updateCookies(rawCookies, url.host, url.path);
    }
  }

}

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
  final Session session = Session();
  bool isAuthenticated = false;
   
  
  Future<void> getSessionAttributes() async {

    final file = await File('data.json');
    final fileContent = await file.readAsString();

    Map<String, dynamic> jsonContent = jsonDecode(fileContent);
  
    if (jsonContent.keys.contains('cookies')) {
      session.cookies.updateCookies(jsonContent['cookies'], 'imsnsit.org', '/');
    }
    print(jsonContent.keys);
    if (jsonContent.containsKey('profileUrl') && jsonContent['profileUrl'] != null) {
      this.profileUrl = jsonContent['profileUrl'];
    }

    if (jsonContent.containsKey('myActivitiesUrl') && jsonContent['myActivitiesUrl'] != null) {
      this.myActivitiesUrl = jsonContent['myActivitiesUrl'];
    }
  } 

  void store(Map<String, String> data) async {
    final file = await File('data.json');

    var fileContent = await file.readAsString();

    Map<String, dynamic> jsonData = jsonDecode(fileContent);

    jsonData.addAll(data);

    fileContent = jsonEncode(jsonData);

    file.writeAsString(fileContent);
  }

  Future<bool> isUserAuthenticated() async {
    await getSessionAttributes();
    print(session.cookies.cookies);
      try {
        final response = await session.get(Uri.parse(profileUrl!), headers: baseHeaders);

        if (response.body.contains('Session expired')) {
          return false;
        }
      } catch (e) {
        return false;
      }

    return true;
  }

  Future<void> authenticate() async {

    if (await isUserAuthenticated()) {
      isAuthenticated = true;
      return;
    }

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
    
    Map<String, String> data = {
            'f': '',
            'uid': '***REMOVED***',
            'pwd': '***REMOVED***',
            'HRAND_NUM': hrandNum,
            'fy': '2023-24',
            'comp': 'NETAJI SUBHAS UNIVERSITY OF TECHNOLOGY',
            'cap': cap!,
            'logintype': 'student',
        };

    var response = await session.post(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php'), headers: baseHeaders, data: data);
    
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

    store({
      'cookies': session.getCookies(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php')),
      'profileUrl': profileUrl!,
      'myActivitiesUrl': myActivitiesUrl!
    });

    isAuthenticated = true;

  }

  Future<(String, String)> getCaptcha() async {

    this.baseHeaders.addAll({
          'Referer': 'https://www.imsnsit.org/imsnsit/',
          'Sec-Fetch-User': '?1'
          });

    var response = await session.get(Uri.parse('https://www.imsnsit.org/imsnsit/student_login110.php'), headers: baseHeaders);
    response = await session.get(Uri.parse('https://www.imsnsit.org/imsnsit/student_login.php'), headers: baseHeaders);

    final doc = parse(response.body);
    
    String? captchaImage = doc.getElementById('captchaimg')!.attributes['src'];
    captchaImage = Uri.parse(baseUrl.toString()).resolve(captchaImage!).toString();
    String? hrand = doc.getElementById('HRAND_NUM')!.attributes['value'];

    return (captchaImage, hrand!);
  }

  void getProfileData() async {
    if (!isAuthenticated) {
      authenticate();
    }
    print(profileUrl);
    final response = await http.get(Uri.parse(profileUrl!), headers: baseHeaders);
    print(response.body);
  }

}
void main() async {

  // final ims = Ims();
  // await ims.authenticate();
  // ims.getProfileData();


  final headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.119 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate, br',
    //'Referer': 'https://www.imsnsit.org/imsnsit/plum_url.php?xS8C9E3DSlqtqdmz1vDdC+8QlIk4lWi6nzu8ujac4HB9DQxz9vD/KnyhycO5HA1pkhGH+jvvgZoKNcATZMpgmQ==',
    'Connection': 'keep-alive',
    'Cookie': 'PHPSESSID=53hljq61cst22vdcchj951jtl6',
    'Upgrade-Insecure-Requests': '1',
    'Sec-Fetch-Dest': 'frame',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'same-origin',
    'Sec-Fetch-User': '?1',
    'Accept-Encoding': 'gzip',
  };

  final url = Uri.parse('https://www.imsnsit.org/imsnsit/plum_url.php?tXSfLx1qF8T2Een4lOffgVuX/+thUqgUtWXVKyN+rH5ebsz02HawOqP4jnwsz0DCHu843s8Alnpp97X1jzO0Z9MqlHj0UnN7c3DH38y+HBE=');

  final res = await http.get(url, headers: headers);
  final status = res.statusCode;
  if (status != 200) throw Exception('http.get error: statusCode= $status');
  print(res.request!.url);
  print(res.body);


}