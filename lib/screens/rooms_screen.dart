import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/model/room.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final streamController = StreamController<List<Room>>();
    context.read<ImsProvider>().ims.roomsList(streamController: streamController);
      return Scaffold(
        appBar: AppBar(
          title: const Text("Unscheduled APJ Rooms"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {
              context.read<ImsProvider>().ims.roomsList(streamController: streamController);
            }, icon: Icon(Icons.refresh, color: Theme.of(context).textTheme.bodyLarge!.color,))
          ],
        ),
        body: StreamBuilder(stream: streamController.stream, builder: ((context, AsyncSnapshot<List<Room>> snapshot) {
        
          if (snapshot.hasData) {
            return GridView.builder(itemCount: snapshot.data!.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemBuilder: (_, index) {
              return RoomCard(room: snapshot.data![index],);
            });
          } else {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onBackground,));
          }
          }
        )),
      );
  }
}


class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Align(alignment: Alignment.center,child: Text(room.name, style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontFamily: GoogleFonts.lexend().fontFamily)),),
            room.mon!.isNotEmpty ? RoomDayData(day: 'Mon', data: room.mon!) : const SizedBox.shrink(),
            room.tue!.isNotEmpty ? RoomDayData(day: 'Tue', data: room.tue!) : const SizedBox.shrink(),
            room.wed!.isNotEmpty ? RoomDayData(day: 'Wed', data: room.wed!) : const SizedBox.shrink(),
            room.thu!.isNotEmpty ? RoomDayData(day: 'Thu', data: room.thu!) : const SizedBox.shrink(),
            room.fri!.isNotEmpty ? RoomDayData(day: 'Fri', data: room.fri!) : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class RoomDayData extends StatelessWidget {
  const RoomDayData({super.key, required this.day, required this.data});

  final String day;
  final List<String> data;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontFamily: GoogleFonts.lexend().fontFamily)),
            ...data.map((e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('\u2022 $e'),
            )).toList()
          ],
        ),
      ),
    );
  }
}