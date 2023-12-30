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
      subject = entry.value['name'];
      total = entry.value['Overall Class'];
      present = entry.value['Overall  Present'];
      absent = entry.value['Overall Absent'];
      percentage = entry.value['Overall (%)'];
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
        return const CircularProgressIndicator();
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
                children: [
                Text(data.code, style: GoogleFonts.lexend(fontSize: 30, color: Theme.of(context).colorScheme.onBackground)),
                SizedBox(
                  width: 100,
                  child: Text(data.subject, style: GoogleFonts.lexend(fontSize: 12), overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 25,),
                Text("Attended: ${data.present}", style: GoogleFonts.lexend(fontSize: 15)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data.percentage, style: GoogleFonts.lexend(fontSize: 48)),
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