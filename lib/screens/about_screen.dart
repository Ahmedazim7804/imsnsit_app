import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/version.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> goToGithubPage() async {
    final Uri url = Uri.parse('https://github.com/ahmedazim7804/imsnsit_app');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {

    String currentVersion = context.read<VersionProvider>().currentVersion;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/nsut.png', height: 160, width: 160,),
            const SizedBox(height: 32,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text("About App", style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ListTile(
                        leading: Icon(Icons.person, color: Theme.of(context).colorScheme.onBackground, size: 32,),
                        title: Text("Developer", style: GoogleFonts.lexend(fontSize: 16),),
                        subtitle: const Text('Ajeem Ahmad, IT - 1'),
                      ),
                      ListTile(
                        leading: Icon(Icons.email, color: Theme.of(context).colorScheme.onBackground, size: 32,),
                        title: Text("Email", style: GoogleFonts.lexend(fontSize: 16),),
                        subtitle: const Text('Ahmedazim7804@gmail.com'),
                      ),
                      InkWell(
                        onTap: goToGithubPage,
                        child: ListTile(
                          leading: Image.asset('assets/github.png', color: Theme.of(context).colorScheme.onBackground, height: 32, width: 32,),
                          title: Text("Github", style: GoogleFonts.lexend(fontSize: 16),),
                          subtitle: const Text('Source code, issues and information'),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.info, color: Theme.of(context).colorScheme.onBackground, size: 32,),
                        title: Text("Version", style: GoogleFonts.lexend(fontSize: 16),),
                        subtitle: Text(currentVersion),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}