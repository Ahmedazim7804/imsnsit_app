import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  void goToReleasePage() async {
    final Uri url = Uri.parse(
        'https://github.com/ahmedazim7804/imsnsit_app/releases/latest');

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Update Available"),
      content: const Text(
          'A new version of this app is available.\nWould you like to update it now?'),
      actions: [
        TextButton(
            onPressed: () {
              goToReleasePage();
              context.pop(true);
            },
            child: Text(
              "UPDATE NOW",
              style: GoogleFonts.lexend(
                  color: Theme.of(context).colorScheme.onSurface),
            )),
        TextButton(
            onPressed: () {
              context.pop(true);
            },
            child: Text("LATER",
                style: GoogleFonts.lexend(
                    color: Theme.of(context).colorScheme.onSurface)))
      ],
    );
  }
}
