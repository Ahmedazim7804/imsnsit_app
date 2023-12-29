import 'package:http/http.dart' as http;
import 'package:cookie_store/cookie_store.dart';
import 'package:http_session/http_session.dart';

class Session {
  final client = http.Client();
  CookieStore cookies = CookieStore();

  int maxRedirects;

  Session({this.maxRedirects = 15});


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
    String host = url.host;
    String path = url.path;

    if (host.substring(0, 4) == 'www.') {
      host = host.substring(4);
    }

    String cookieHeader = CookieStore.buildCookieHeader(cookies.getCookiesForRequest(host, path));

    return cookieHeader;
  }

  void updateCookies(Map<String, String> headers, Uri url) {
    String? rawCookies = headers['set-cookie'];
    if (rawCookies != null) {
      String host = url.host;
      String path = url.path;

      if (host.substring(0, 4) == 'www.') {
        host = host.substring(4);
      }
      cookies.updateCookies(rawCookies, host, path);
    }
  }

}