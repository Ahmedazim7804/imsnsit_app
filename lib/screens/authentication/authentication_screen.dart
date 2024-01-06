import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:provider/provider.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
        
    Ims ims = Provider.of<ImsProvider>(context).ims;
    
    ims.isUserAuthenticated().then((data) {
      if (data) {
        context.go('/rooms');
      } else {
        if (ims.username != null && ims.password != null) {
        context.go('/authentication/auto_login');
      } else {
        context.go('/authentication/login_screen');
      }
      }
      
    });

    return const CircularProgressIndicator();
  }
}