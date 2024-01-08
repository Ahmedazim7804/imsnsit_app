import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';

class SubjectAttandanceScreen extends StatelessWidget {
  const SubjectAttandanceScreen({super.key, required this.subjectCode, required this.subject});

  final String subjectCode;
  final String subject;


  Future<Map<String, dynamic>> onPress() async {
    return {"Jan-02": 1, "Jan-03": 1, "Jan-04": 0, "Jan-05": "GH"};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ImsProvider>().ims.getAbsoulteAttandanceData(),
      builder: (context, snapshot) { 
        
        if (snapshot.hasData) {
          
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Card(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(subject, style: GoogleFonts.lexend(fontSize: 16),),
                            Text(subjectCode, style: GoogleFonts.lexend(fontSize: 14)),
                          ],
                        ),
                      ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data![subjectCode]!.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                    itemBuilder: (context, index) {
                      final entry = snapshot.data![subjectCode].entries.elementAt(index);
                      return AttandanceDayCard(
                        day: entry.key,
                        value: "${entry.value}",
                      );
                    },
                    )
                ],
              ),
            ),
          );

        } else {
          return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onBackground,),);
        }
      }
    );
  }
}

class AttandanceDayCard extends StatelessWidget {
  const AttandanceDayCard({super.key, required this.day, required this.value});

  final String day;
  final String value;

  Color? get cardColor {
    if (value.contains('1')) {
      return Colors.green.withAlpha(150);
    } else if (value.contains('0')) {
      return Colors.red.withAlpha(150);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    
    return Card(
      color: cardColor ?? Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(day, style: GoogleFonts.lexend(),),
          Text(value, style: GoogleFonts.lexend(),),
        ],
      ),
    );
  }
}