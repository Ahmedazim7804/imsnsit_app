import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});


  Widget popup(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 169, 37, 16),
      title: Text('An error has occured', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),),
      content: Text('Username or password is incorrect. Try Again', style: GoogleFonts.roboto(),),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Try Captcha', style: TextStyle(color: Colors.white),)),
        TextButton(onPressed: () {}, child: const Text("Ok", style: TextStyle(color: Colors.white),)),
      ],
    );
  } 

  @override
  Widget build(BuildContext context) {

    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    void onSubmit() {
      String username = usernameController.text;
      String password = passwordController.text;

      showDialog(context: context, builder: popup);

    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Welcome to", style: GoogleFonts.habibi(fontSize: 36, fontWeight: FontWeight.bold),),
          Image.asset('assets/nsut.png', width: 100, height: 100,),
          const SizedBox(height: 25,),
          Text('Enter your credentials to log in your account', style: GoogleFonts.habibi(fontSize: 15),),
          const SizedBox(height: 25,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSecondary,
                isDense: true,
                prefixIcon: const Icon(Icons.person_rounded),
                hintText: "Enter your username",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))
                )
              ),),
          ),
          Padding(  
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSecondary,
                isDense: true,
                prefixIcon: const Icon(Icons.lock_rounded),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))
                )
              ),),
          ),
          ElevatedButton(
            onPressed: onSubmit, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))
              ),
            child: Text("Submit", style: GoogleFonts.habibi(fontSize: 15, fontWeight: FontWeight.w600),),)
        ],
      ),
    );
  }
}