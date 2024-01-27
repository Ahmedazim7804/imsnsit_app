import 'dart:convert';

import 'package:imsnsit/model/room.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DataType { attendance, absoluteAttendance, rooms, profile }

class Functions {
  static Future<String> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file.path;
  }

  static Future<String> downloadFile(String imageUrl,
      {String? referrer}) async {
    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.119 Safari/537.36',
    };

    if (referrer != null) {
      headers['Referer'] = referrer;
    }

    FileInfo fileInfo = await DefaultCacheManager()
        .downloadFile(imageUrl, authHeaders: headers);

    String filePath = fileInfo.file.path;

    return filePath;
  }

  static Future<String> performOcr(String imagePath) async {
    String text = await FlutterTesseractOcr.extractText(imagePath,
        language: 'mydigits',
        args: {
          "psm": "11",
        });

    return text;
  }

  static Future<void> saveJsonToFile(String jsonData, DataType dataType) async {
    Directory appDir = await getApplicationDocumentsDirectory();

    late final String filePath;
    late final String prefKey;
    if (dataType == DataType.attendance) {
      filePath = appDir.absolute.uri.resolve("attendance.json").toFilePath();
      prefKey = 'attendanceDataLastUpdated';
    } else if (dataType == DataType.absoluteAttendance) {
      filePath = appDir.absolute.uri
          .resolve("subjectWiseAttendance.json")
          .toFilePath();
      prefKey = 'subjectWiseAttendanceDataLastUpdated';
    } else if (dataType == DataType.rooms) {
      filePath = appDir.absolute.uri.resolve("rooms.json").toFilePath();
      prefKey = 'roomsDataLastUpdated';
    } else if (dataType == DataType.profile) {
      filePath = appDir.absolute.uri.resolve("profile.json").toFilePath();
      prefKey = 'profileDataLastUpdated';
    }

    final file = File(filePath);

    file.writeAsString(jsonData);

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String date = DateFormat('dd MMM, yyyy HH:mm').format(now);
    sharedPreferences.setString(prefKey, date);

    print("${dataType} data successfully stored");
  }

  static Future<dynamic> getJsonFromFile(DataType dataType) async {
    Directory appDir = await getApplicationDocumentsDirectory();

    late final String filePath;
    if (dataType == DataType.attendance) {
      filePath = appDir.absolute.uri.resolve("attendance.json").toFilePath();
    } else if (dataType == DataType.absoluteAttendance) {
      filePath = appDir.absolute.uri
          .resolve("subjectWiseAttendance.json")
          .toFilePath();
    } else if (dataType == DataType.rooms) {
      filePath = appDir.absolute.uri.resolve("rooms.json").toFilePath();
    } else if (dataType == DataType.profile) {
      filePath = appDir.absolute.uri.resolve("profile.json").toFilePath();
    }

    final file = File(filePath);

    String jsonData = await file.readAsString();
    dynamic data = jsonDecode(jsonData);

    late dynamic properData;

    if (dataType == DataType.rooms) {
      // Casting data from dynamic -> List<dynamic> -> List<Map<String, dynamici>> -> List<Room>
      properData = (data as List<dynamic>).map((element) {
        return Room.fromJson(jsonDecode(element));
      }).toList();
    } else if (dataType == DataType.attendance) {
      properData = data as Map<String, dynamic>;
    } else if (dataType == DataType.profile) {
      // Casting data from dynamic -> Map<String, dynamic> -> Map<String, String>
      properData = (data as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value.toString()));
    } else if (dataType == DataType.absoluteAttendance) {
      properData = data as Map<String, dynamic>;
    }

    print("${dataType} data successfully loaded");

    return properData;
  }
}
