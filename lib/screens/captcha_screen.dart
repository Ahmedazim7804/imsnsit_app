import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:imsnsit/model/imsnsit.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  void onSubmit(Ims ims) async {

    print(await ims.getCaptcha());

  }

  @override
  Widget build(BuildContext context) {

    TextEditingController controller = TextEditingController();

    return ChangeNotifierProvider<ImsProvider>(
      create: (context) => ImsProvider(),
      child: Consumer<ImsProvider>(
        builder: (context, ImsProvider, child) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CaptchImage(ims: ImsProvider.ims),
              TextField(
                controller: controller,
              ),
              ElevatedButton(onPressed: () {onSubmit(ImsProvider.ims);}, child: const Text("Submit"))
            ],
          ),
        );}
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