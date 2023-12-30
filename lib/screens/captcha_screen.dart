import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';

class CaptchaScreen extends StatelessWidget {
  const CaptchaScreen({super.key});

  void onSubmit(Ims ims, TextEditingController controller) async {

    String cap = controller.text;
    
    ims.authenticate(cap);

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
        
          return Image.memory(snapshot.data!);
        
        } else {
          return const Text('Loading....');
        }
      
      } 
      );
  }
}