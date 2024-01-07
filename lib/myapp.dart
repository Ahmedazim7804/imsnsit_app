import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ImsProvider>().ims.getInitialData().then((data) => context.go('/authentication/authentication_screen'));
    return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,));
  }
}