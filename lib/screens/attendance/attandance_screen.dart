import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/provider/mode_provider.dart';
import 'package:imsnsit/widgets/conditional_visibilty.dart';
import 'package:imsnsit/widgets/outdated_data_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class AttandanceScreen extends StatefulWidget {
  const AttandanceScreen({super.key});

  @override
  State<AttandanceScreen> createState() => _AttandanceScreenState();
}

class _AttandanceScreenState extends State<AttandanceScreen> {
  late final bool _isOffline = context.read<ModeProvider>().offline;
  late final OverlayPortalController overlayPortalController =
      OverlayPortalController();
  late final lastUpdated =
      context.read<SharedPreferences>().getString('attendanceDataLastUpdated');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isOffline) {
        overlayPortalController.show();
      } else {
        overlayPortalController.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: overlayPortalController,
      overlayChildBuilder: (ctx) => outdatedDataOverlay(ctx,
          lastUpdated: lastUpdated!,
          action: () => context.go('/initial_screen')),
      child: FutureBuilder(
          future: _isOffline
              ? Functions.getJsonFromFile(DataType.attendance)
              : Provider.of<ImsProvider>(context).ims.getAttandanceData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<SubjectAttandance> subjectAttandance =
                  (snapshot.data! as Map<String, dynamic>)
                      .entries
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
          }),
    );
  }
}

class AttandanceCard extends StatelessWidget {
  const AttandanceCard({super.key, required this.data});
  final SubjectAttandance data;

  int get attendenceNeeded {
    double attendenceNeeded = 0;
    double present = double.parse(data.present);
    double total = double.parse(data.total);

    while ((present + attendenceNeeded) / (total + attendenceNeeded) < 0.75) {
      attendenceNeeded += 1;
    }

    return attendenceNeeded.ceil();
  }

  int get bunkPossible {
    int bunk = 0;
    double present = double.parse(data.present);
    double total = double.parse(data.total);

    while ((present) / (total + bunk + 1) >= 0.75) {
      bunk++;
    }

    return bunk;
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = context.read<ModeProvider>().offline;

    late final bool attendanceCardClickable;

    if (isOffline) {
      attendanceCardClickable = context
          .read<SharedPreferences>()
          .containsKey('subjectWiseAttendanceDataLastUpdated');
    } else {
      attendanceCardClickable = true;
    }

    final Color red = Colors.redAccent.withAlpha(150);
    final Color green = Colors.greenAccent.withAlpha(150);

    double attendancePerc =
        double.parse(data.percentage.substring(0, data.percentage.length - 1));

    Color cardColor = attendancePerc > 75 ? green : red;

    return InkWell(
      onTap: attendanceCardClickable
          ? () => context.pushNamed('subject_attendance', pathParameters: {
                'subject': data.subject,
                'subjectCode': data.code
              })
          : null,
      child: SizedBox(
        height: attendancePerc >= 75 ? 190 : 170,
        child: Card(
          margin: const EdgeInsets.all(15),
          color: cardColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: LinearProgressIndicator(
                              minHeight: 20,
                              borderRadius: BorderRadius.circular(10),
                              value: double.parse(data.percentage.substring(
                                      0, data.percentage.length - 1)) /
                                  100,
                              backgroundColor: Colors.white24,
                              color: attendancePerc > 75 ? green : red,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(data.percentage,
                            style: GoogleFonts.lexend(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Total: ${data.total}',
                            style: GoogleFonts.lexend(fontSize: 15)),
                        Text("Attended: ${data.present}",
                            style: GoogleFonts.lexend(fontSize: 15)),
                        attendancePerc < 75
                            ? Text('Need: $attendenceNeeded',
                                style: GoogleFonts.lexend(fontSize: 15))
                            : const SizedBox.shrink()
                      ],
                    ),

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
              attendancePerc >= 75 ? const Spacer() : const SizedBox.shrink(),
              attendancePerc >= 75
                  ? Container(
                      alignment: Alignment.center,
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 22, 58, 23),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      child: Text(
                          "You can bunk $bunkPossible classes without going below 75%.",
                          style: GoogleFonts.lexend(fontSize: 11)),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
