import 'package:collection/collection.dart';
import 'package:html/dom.dart';

enum Result { rowWise, columnWise, columnAndRowWise }

class TableParser {
  const TableParser(
      {required this.table,
      required this.firstRowIsInfo,
      required this.hasRowHeaders,
      required this.hasColumnHeaders,
      required this.result,
      this.replace});

  final Element table;
  final bool firstRowIsInfo;
  final bool hasRowHeaders;
  final bool hasColumnHeaders;
  final Result result;
  final Map<String, String>? replace;

  String htmlCleanup(String htmlText) {
    replace!.forEach((from, to) {
      htmlText = htmlText.replaceAll(from, to);
    });

    return htmlText;
  }

  String getTableInfo() {
    List<List<String>> rows = getRowsFromTable(table);

    if (firstRowIsInfo) {
      final tableInfo = rows[0][0];
      return tableInfo;
    } else {
      return '';
    }
  }

  List<List<String>> getRowsFromTable(Element table) {
    final List<List<String>> rowsList = [];

    for (Element rowElement in table.querySelectorAll('tr')) {
      final List<String> row = [];

      for (Element cell in rowElement.querySelectorAll('td')) {
        String cellText = cell.innerHtml;
        if (replace != null) {
          cellText = htmlCleanup(cellText);
        }
        row.add(cellText);
      }

      rowsList.add(row);
    }

    return rowsList;
  }

  Map<String, dynamic> rowAndColumnWiseParse(List<String> columnHeaders,
      List<String> rowHeaders, List<List<String>> rows) {
    final Map<String, dynamic> data = {};

    for (List pair in IterableZip([columnHeaders, rows])) {
      final columnHeader = pair[0] as String;
      final row = pair[1] as List<String>;

      final entry = {};

      for (int cellCount = 0; cellCount < row.length; cellCount += 1) {
        entry[rowHeaders[cellCount]] = row[cellCount];
      }

      data[columnHeader] = entry;
    }

    return data;
  }

  Map<String, dynamic> columnWiseParse(
      List<String> columnHeaders, List<List<String>> rows) {
    final Map<String, dynamic> data = {};

    for (List pair in IterableZip([columnHeaders, rows])) {
      final columnHeader = pair[0] as String;
      final row = pair[1] as List<String>;

      final entries = [];

      for (int cellCount = 0; cellCount < row.length; cellCount += 1) {
        entries.add(row[cellCount]);
      }

      data[columnHeader] = entries;
    }

    return data;
  }

  Map<String, dynamic> rowWiseParse(
      List<String> rowHeaders, List<List<String>> rows) {
    final Map<String, dynamic> data = {};

    for (int columnCount = 0; columnCount < rows.length; columnCount += 1) {
      String rowHeader = rowHeaders[columnCount];

      final List<String> entries = [];

      for (List<String> row in rows) {
        entries.add(row[columnCount]);
      }

      data[rowHeader] = entries;
    }

    return data;
  }

  Map<String, dynamic> convertToJson() {
    List<List<String>> rows = getRowsFromTable(table);

    if (firstRowIsInfo) {
      final tableInfo = rows[0][0];
      rows.removeAt(0);
    }

    late List<String> rowHeaders;
    if (hasRowHeaders) {
      rowHeaders = rows[0];
      if (rowHeaders[0].isEmpty) {
        rowHeaders.removeAt(0);
      }
      rows.removeAt(0);
    }

    late final List<String> columnHeaders;
    if (hasColumnHeaders) {
      columnHeaders = [];

      for (int rowCount = 0; rowCount < rows.length; rowCount += 1) {
        final List<String> row = rows[rowCount];

        final column = row[0];
        columnHeaders.add(column);

        rows[rowCount].removeAt(0);
      }
    }

    late final Map<String, dynamic> data;

    if (result == Result.columnAndRowWise) {
      data = rowAndColumnWiseParse(columnHeaders, rowHeaders, rows);
    }

    if (result == Result.columnWise) {
      data = columnWiseParse(columnHeaders, rows);
    }

    if (result == Result.rowWise) {
      data = rowWiseParse(rowHeaders, rows);
    }

    return data;
  }
}
