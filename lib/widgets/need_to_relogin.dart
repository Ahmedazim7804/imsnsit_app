import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NeedToRelogin extends StatelessWidget {
  const NeedToRelogin({super.key});

  void logout() async {
    final Uri url = Uri.parse(
        'https://github.com/ahmedazim7804/imsnsit_app/releases/latest');

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("You Might Need to Logout"),
      content: const Text(
          'Some urls might be need to updated, for that you need to logout.\nif you still see this Dialog after logout and relogin, Please Contact the developer'),
      actions: [
        TextButton(
            onPressed: () {
              context.pop(true);
            },
            child: Text("LATER",
                style: GoogleFonts.lexend(
                    color: Theme.of(context).colorScheme.onSurface))),
        ElevatedButton(
            onPressed: () {
              context.read<ImsProvider>().ims.logout();
              context.go('/initial_screen');
              context.pop(true);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer),
            child: Text(
              "LOGOUT",
              style: GoogleFonts.lexend(
                  color: Theme.of(context).colorScheme.onSurface),
            )),
      ],
    );
  }
}
