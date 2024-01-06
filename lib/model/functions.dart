import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class Functions {


  static Future<String> getImageFileFromAssets(String path) async {
      final byteData = await rootBundle.load('assets/$path');

      final file = File('${(await getTemporaryDirectory()).path}/$path');
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      return file.path;

    }

  static Future<String> downloadFile(String imageUrl, {String? referrer}) async {

    final headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.119 Safari/537.36',
      };

    if (referrer != null) {
      headers['Referer'] = referrer;
    }
      
    
    FileInfo fileInfo = await DefaultCacheManager().downloadFile(
        imageUrl, 
        authHeaders: headers
    );

    String filePath = fileInfo.file.path;
    
    return filePath;

  }

  static Future<String> performOcr(String imagePath) async {

    String text = await FlutterTesseractOcr.extractText(
        imagePath,
        language: 'mydigits',
        args: {
          "psm": "11",
        }
        );
    
    return text;

  }

}