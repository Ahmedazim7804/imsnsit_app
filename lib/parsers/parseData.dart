import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:collection/collection.dart';

class ParseData {
  static Map<String, String> parseProfileData(String htmlContent) {
    final doc = parse(htmlContent);

    Map<String, String> data = {};

    final elements = doc.getElementsByClassName('plum_fieldbig');
    for (Element element in elements) {
      final tdTags = element.querySelectorAll('td');

      if (tdTags.length == 2) {
        String text = tdTags[0].text;
        String value = tdTags[1].text;

        data[text] = value;
      } else {
        final image = tdTags[0].querySelectorAll('img');
        if (image.isNotEmpty) {
          final imagePath = image[0].attributes['src'];
          data['profile_image'] = imagePath!;
        }
      }
    }

    return data;
  }

  static Map<String, dynamic> parseEnrolledCoursesData(String htmlContent) {
    final doc = parse(htmlContent);

    Map<String, dynamic> data = {};

    final table = doc.getElementsByTagName('table')[0];
    final List rows = table.querySelectorAll('tr').sublist(2);

    for (Element row in rows) {
      List<Element> rowElements = row.querySelectorAll('td');

      List<String?> rowTexts =
          rowElements.map((element) => element.text).toList();

      String? subjectCode = rowTexts[1];
      String? subjectName = rowTexts[2];
      String? group = rowTexts[4];
      String? credits = rowTexts[6];
      String? imsApproved = rowTexts[8];
      String? userApproved = rowTexts[9];

      data[subjectCode!] = {
        'subjectName': subjectName,
        'group': group,
        'credits': credits,
        'imsApproved': imsApproved,
        'userApproved': userApproved
      };
    }

    return data;
  }

  static String parseSemester(String htmlContent) {
    final doc = parse(htmlContent);

    final divTag = doc.querySelector('html body div#div2.plum_head');
    String semsester = divTag!.firstChild!.text!.split('Semester ')[1];

    return semsester;
  }

  static Map<String, Map<String, String>> parseAbsoluteAttandanceData(
      String htmlContent) {
    final doc = parse(htmlContent);
    final subjectTags = doc
        .querySelectorAll(
            'html body div#myreport table.plum_fieldbig tbody tr.plum_head')[2]
        .querySelectorAll('td');

    final subjects = subjectTags.sublist(1).map((tag) => tag.text).toList();

    Map<String, Map<String, String>> data =
        Map.fromEntries(subjects.map((subject) => MapEntry(subject, {})));

    final rows = doc.querySelectorAll(
        'html body div#myreport table.plum_fieldbig tbody tr');

    for (final row in rows) {
      if (!row.attributes.containsKey('class')) {
        List<Element> tdTags = row.querySelectorAll('td');

        if (tdTags.length > 2) {
          List<String?> tdTagValues = tdTags.map((tag) => tag.text).toList();

          String day = tdTagValues[0]!;
          List<String?> attandanceData = tdTagValues.sublist(1);

          for (List<String?> pair in IterableZip([attandanceData, subjects])) {
            String subject = pair[1]!;
            String attandance = pair[0]!;

            if (attandance.isNotEmpty) {
              data[subject]![day] = attandance;
            }
          }
        }
      }
    }

    return data;
  }

  static Map<String, Map<String, String>> parseAttandanceData(
      String htmlContent, Map<String, dynamic> courses) {
    final doc = parse(htmlContent);
    final subjectTags = doc
        .querySelectorAll(
            'html body div#myreport table.plum_fieldbig tbody tr.plum_head')[2]
        .querySelectorAll('td');

    final subjects = subjectTags.sublist(1).map((tag) => tag.text).toList();

    Map<String, Map<String, String>> data = {};

    for (String subject in subjects) {
      String subjectName;

      if (courses.containsKey(subject)) {
        subjectName = courses[subject]['subjectName'];
      } else {
        subjectName = 'unknown';
      }

      data[subject] = {'name': subjectName};
    }
    final allRows = doc.querySelectorAll(
        'html body div#myreport table.plum_fieldbig tbody tr.plum_head');
    final requiredRows = allRows.sublist(allRows.length - 4);

    for (final row in requiredRows) {
      List<Element> tdTags = row.querySelectorAll('td');
      List<String?> tdTagValues = tdTags.map((tag) => tag.text).toList();

      String key = tdTagValues[0]!;
      List<String?> values = tdTagValues.sublist(1);

      for (List<String?> pair in IterableZip([values, subjects])) {
        String subject = pair[1]!;
        String value = pair[0]!;

        data[subject]![key] = value;
      }
    }

    return data;
  }

  static Map<String, List<String>> parseRoomData(String htmlContent) {
    final doc = parse(htmlContent);
    final rows = doc.querySelectorAll('tr');

    Map<String, List<String>> data = {};

    final timesTags = rows[2].querySelectorAll('td').sublist(3, 11);
    List<String> times = [];

    for (Element tag in timesTags) {
      final tagText = tag.querySelector('b');
      String time = tagText!.innerHtml.split('<br>')[1];
      times.add(time);
    }

    for (Element row in rows.sublist(3, 7)) {
      final allCells = row.querySelectorAll('td');

      String day = allCells[0].text;
      final cellTexts =
          allCells.sublist(3, 11).map((element) => element.text).toList();

      for (List<String?> pair in IterableZip([times, cellTexts])) {
        String time = pair[0]!;

        if (pair[1]!.trim().isEmpty) {
          if (data.containsKey(day)) {
            data[day]!.add(time);
          } else {
            data[day] = [time];
          }
        }
      }
    }

    return data;
  }
}
