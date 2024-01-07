import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';
import 'package:imsnsit/model/functions.dart';
import 'dart:io';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {
              context.read<ImsProvider>().ims.logout();
              context.pushReplacement('/authentication/login_screen');
            }, icon: Icon(Icons.logout, color: Theme.of(context).textTheme.bodyLarge!.color,))
          ],
        ),
        body: FutureBuilder(
          future: context.read<ImsProvider>().ims.getProfileData(), 
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              
              Map<String, String> data = snapshot.data!;
        
              return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileImage(imageUrl: data['profileImage']!, referrer: data['profileUrl']!),
                InfoCard(keys: 'Roll No.', value: data['Student ID']!,),
                InfoCard(keys: 'Name', value: data['Student Name']!,),
                InfoCard(keys: 'DOB', value: data['DOB']!,),
                InfoCard(keys: 'Gender', value: data['Gender']!,),
                InfoCard(keys: 'Admission', value: data['Admission']!,),
                InfoCard(keys: 'Catergoy', value: data['Category']!,),
                InfoCard(keys: 'Branch', value: data['Branch Name']!.replaceAll(' ', '\n'),),
                InfoCard(keys: 'Degree', value: data['Degree']!,),
                InfoCard(keys: 'Section', value: data['Section']!,)
              ],
            ),
          )
          );
        
            } else {
              return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onBackground,));
            }
          })
          ),
      );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.keys, required this.value});

  final String keys;
  final String value;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Theme.of(context).colorScheme.background.withAlpha(120),
        child: SizedBox(
          width: double.infinity,
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(keys, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontFamily: GoogleFonts.lexend().fontFamily),),
            trailing: Text(value, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontFamily: GoogleFonts.lexend().fontFamily)),
          )
          ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key, required this.imageUrl, required this.referrer});

  final String imageUrl;
  final String referrer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: FutureBuilder(
        future: Functions.downloadFile(imageUrl, referrer: referrer),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return ClipOval(
                child: Image.file(File(snapshot.data!), height: 100, width: 100,)
            );
          } else {
            return ClipOval(
                child: Image.asset('assets/user.png', height: 100, width: 100),
            );
          }
        }
        )
      ),
    );
  }
}