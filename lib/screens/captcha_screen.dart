import 'package:flutter/material.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class CaptchaScreen extends StatelessWidget {
  const CaptchaScreen({super.key});

  void onSubmit(Ims ims, TextEditingController controller) async {

    String cap = controller.text;
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username')!;
    String password = prefs.getString('password')!;

    ims.authenticate(cap, username, password);

  }

  @override
  Widget build(BuildContext context) {

    final ims = Provider.of<ImsProvider>(context).ims;

    TextEditingController controller = TextEditingController();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CaptchImage(ims: ims),
          TextField(
            controller: controller,
          ),
          ElevatedButton(onPressed: () {onSubmit(ims, controller);}, child: const Text("Submit"))
        ],
      ),
    );
  }
}

class CaptchImage extends StatelessWidget {
  const CaptchImage({super.key, required this.ims});
  
  final Ims ims;

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: ims.getCaptcha(),
      builder: (context, snapshot) {

        if (snapshot.hasData) {
        
          return Image.asset(snapshot.data!);
        
        } else {
          return const Text('Loading....');
        }
      
      } 
      );
  }
}