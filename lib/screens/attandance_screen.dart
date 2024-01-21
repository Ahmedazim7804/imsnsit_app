import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';

class SubjectAttandance {
  late final String code;
  late final String subject;
  late final String total;
  late final String present;
  late final String absent;
  late final String percentage;

  SubjectAttandance({required MapEntry entry}) {
    code = entry.key;

    try {
      subject = entry.value['name'];
    } catch (e) {
      subject = 'subject';
    }
    try {
      total = entry.value['Overall Class'];
    } catch (e) {
      total = '0';
    }
    try {
      present = entry.value['Overall  Present'];
    } catch (e) {
      present = '0';
    }
    try {
      absent = entry.value['Overall Absent'];
    } catch (e) {
      absent = '0';
    }
    try {
      percentage = entry.value['Overall (%)'];
    } catch (e) {
      percentage = '0%';
    }
  }
}

class AttandanceScreen extends StatelessWidget {
  const AttandanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<ImsProvider>(context).ims.getAttandanceData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<SubjectAttandance> subjectAttandance = snapshot.data!.entries
                .map((entry) => SubjectAttandance(entry: entry))
                .toList();

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: subjectAttandance
                        .map((item) => AttandanceCard(
                              data: item,
                            ))
                        .toList(),
                  ),
                ),
              ),
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onBackground,
            ));
          }
        });
  }
}

class AttandanceCard extends StatelessWidget {
  const AttandanceCard({super.key, required this.data});
  final SubjectAttandance data;

  int get attendenceNeeded {
    double _attendenceNeeded = 0;

    if (double.parse(data.percentage.substring(0, data.percentage.length - 1)) <
        75) {
      _attendenceNeeded =
          (int.parse(data.total) * 0.75) - (int.parse(data.present));
    }
    return _attendenceNeeded.ceil();
  }

  @override
  Widget build(BuildContext context) {
    final Color red = Colors.redAccent.withAlpha(150);
    final Color green = Colors.greenAccent.withAlpha(150);

    double attendancePerc =
        double.parse(data.percentage.substring(0, data.percentage.length - 1));

    Color cardColor = attendancePerc > 75 ? green : red;

    return InkWell(
      onTap: () => context.pushNamed('subject_attendance',
          pathParameters: {'subject': data.subject, 'subjectCode': data.code}),
      child: SizedBox(
        height: 170,
        child: Card(
          margin: const EdgeInsets.all(15),
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.subject,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lexend(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onBackground)),
                Text(data.code,
                    style: GoogleFonts.lexend(fontSize: 16),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 200,
                      alignment: Alignment.centerLeft,
                      child: LinearProgressIndicator(
                        minHeight: 20,
                        borderRadius: BorderRadius.circular(10),
                        value: double.parse(data.percentage
                                .substring(0, data.percentage.length - 1)) /
                            100,
                        backgroundColor: Colors.white24,
                        color: attendancePerc > 75 ? green : red,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(data.percentage,
                        style: GoogleFonts.lexend(fontSize: 20)),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Total: ${data.total}',
                        style: GoogleFonts.lexend(fontSize: 15)),
                    Text("Attended: ${data.present}",
                        style: GoogleFonts.lexend(fontSize: 15)),
                    Text('Need: ${attendenceNeeded}',
                        style: GoogleFonts.lexend(fontSize: 15))
                  ],
                )
                // Padding(
                //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                //     child: Text("Attended: ${data.present}",
                //         style: GoogleFonts.lexend(fontSize: 15))),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text(data.percentage,
                //         style: GoogleFonts.lexend(fontSize: 40)),
                //     const SizedBox(
                //       height: 25,
                //     ),
                //     Text('Total: ${data.total}',
                //         style: GoogleFonts.lexend(fontSize: 15))
                //   ],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
