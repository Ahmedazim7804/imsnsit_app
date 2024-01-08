import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:imsnsit/model/functions.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});


  Widget popup(BuildContext context) {

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 169, 37, 16),
      title: Text('An error has occured', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),),
      content: Text('Username or password is incorrect. Try Again', style: GoogleFonts.roboto(),),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text("Ok", style: TextStyle(color: Colors.white),)),        
      ],
    );
  } 


  @override
  Widget build(BuildContext context) {

    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    final ims = Provider.of<ImsProvider>(context).ims;

    void showErrorDialog() {
      showDialog(context: context, builder: (context) => popup(context));
    }

    void onSubmit(Ims ims) async {

      context.loaderOverlay.show();
      
      String imageUrl = await ims.getCaptcha();
      String imagePath = await Functions.downloadFile(imageUrl);
      
      String captchaText = await Functions.performOcr(imagePath); 

      String username = usernameController.text;
      String password = passwordController.text;
      
      final authenticationStatus = await ims.authenticate(captchaText, username, password);
      
      context.loaderOverlay.hide();

      if (ims.isAuthenticated) {

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        prefs.setString('password', password);

        context.go('/attandance');
        
      } else {
        
        if (authenticationStatus == LoginProperties.wrongPassword) {
          showErrorDialog();
        }
      }
    }

    return Scaffold(
      body: LoaderOverlay(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Welcome to", style: GoogleFonts.lexend(fontSize: 36, fontWeight: FontWeight.bold),),
              Image.asset('assets/nsut.png', width: 100, height: 100,),
              const SizedBox(height: 25,),
              Text('Enter your credentials to log in your account', style: GoogleFonts.lexend(fontSize: 15),),
              const SizedBox(height: 25,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: usernameController,
                  cursorColor: Theme.of(context).colorScheme.onBackground,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: GoogleFonts.lexend(color: Theme.of(context).colorScheme.onBackground),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primary.withAlpha(150),
                    isDense: true,
                    prefixIcon: const Icon(Icons.person_rounded),
                    hintText: "Enter your username",
                    hintStyle: GoogleFonts.lexend(color: Theme.of(context).colorScheme.onBackground),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    )
                  ),),
              ),
              Padding(  
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TextField(
                  cursorColor: Theme.of(context).colorScheme.onBackground,
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.lexend(color: Theme.of(context).colorScheme.onBackground),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primary.withAlpha(150),
                    isDense: true,
                    prefixIcon: const Icon(Icons.lock_rounded),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    )
                  ),),
              ),
              ElevatedButton(
                onPressed: () async {
                  onSubmit(ims);
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onBackground,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))
                  ),
                child: Text("Submit", style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),),)
            ],
          ),
        ),
      ),
    );
  }
}