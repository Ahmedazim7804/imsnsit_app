import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';

class FacultyTT extends StatelessWidget {
  const FacultyTT(
      {super.key,
      required this.tutor,
      required this.tutorCode,
      required this.sem});

  final String tutor;
  final String tutorCode;
  final String sem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Table"),
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).textTheme.bodyLarge!.color),
      ),
      body: Center(
        child: FutureBuilder(
            future: context.read<ImsProvider>().ims.getFacultyTimeTable(
                tutor: tutor, tutorCode: tutorCode, sem: sem),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final tableRows = snapshot.data!;

                if (tableRows.length > 2) {
                  final tableInfo = tableRows[0][0];
                  final tableHeaderRow = tableRows[1];
                  final tableOtherRows =
                      tableRows.sublist(2, tableRows.length - 1);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tableInfo.replaceAll("\n", ","),
                                style: GoogleFonts.lexend(fontSize: 14),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              DataTable(
                                dataRowMinHeight: 47,
                                dataRowMaxHeight: double.infinity,
                                border: TableBorder.all(
                                    width: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                                columns: tableHeaderRow
                                    .map((e) => DataColumn(label: Text(e)))
                                    .toList(),
                                rows: tableOtherRows.map((row) {
                                  return DataRow(
                                      cells: row
                                          .map((cell) => DataCell(Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Text(
                                                  cell,
                                                ),
                                              )))
                                          .toList());
                                }).toList(),
                              ),
                            ]),
                      ),
                    ),
                  );
                } else {
                  return Text(
                    tableRows[1][1],
                    style: GoogleFonts.lexend(fontSize: 18),
                  );
                }
              } else {
                return CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onBackground);
              }
            }),
      ),
    );
  }
}
