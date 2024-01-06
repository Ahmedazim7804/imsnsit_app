import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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

@RoutePage()
class AttandanceScreen extends StatelessWidget {
  const AttandanceScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
    future: Provider.of<ImsProvider>(context).ims.getAttandanceData(), 
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        print('sdsdsdsd');
        List<SubjectAttandance> subjectAttandance = snapshot.data!.entries.map((entry) => SubjectAttandance(entry: entry)).toList();

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: subjectAttandance.map((item) => AttandanceCard(data: item,)).toList(),
            ),
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }
    );
  }
}

class AttandanceCard extends StatelessWidget {
  const AttandanceCard({super.key, required this.data});
  
  final SubjectAttandance data;

  @override
  Widget build(BuildContext context) {

    Color cardColor = double.parse(data.percentage.substring(0,data.percentage.length-1)) > 75 ? Colors.greenAccent.withAlpha(150) : Colors.redAccent.withAlpha(150);

    return SizedBox(
      height: 150,
      child: Card(
        margin: const EdgeInsets.all(15),
        color: cardColor,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Text(data.code, style: GoogleFonts.lexend(fontSize: 30, color: Theme.of(context).colorScheme.onBackground)),
                Container(
                  width: 100,
                  alignment: Alignment.center,
                  child: Text(data.subject, style: GoogleFonts.lexend(fontSize: 12), overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 25,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                  child: Text("Attended: ${data.present}", style: GoogleFonts.lexend(fontSize: 15))
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data.percentage, style: GoogleFonts.lexend(fontSize: 40)),
                  const SizedBox(height: 25,),
                  Text('Total: ${data.total}', style: GoogleFonts.lexend(fontSize: 15))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}