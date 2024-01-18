import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imsnsit/provider/version.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.read<VersionProvider>().needUpdate) {
        showDialog(context: context, builder: (_) => const UpdateDialog());
      } else {
        context.go('/authentication/authentication_screen');
      }
    });

    return const Scaffold(
        body: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Checking for update... '),
          CircularProgressIndicator()
        ],
      ),
    ));
  }
}

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
              context.go('/authentication/authentication_screen');
            },
            child: const Text("UPDATE NOW")),
        TextButton(
            onPressed: () {
              context.pop();
              context.go('/authentication/authentication_screen');
            },
            child: const Text("LATER"))
      ],
    );
  }
}
