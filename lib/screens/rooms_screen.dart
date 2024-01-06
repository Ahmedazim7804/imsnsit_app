import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final streamController = StreamController<Map<String, Map<String, List<String>>>>();
    // streamController.sink.add([]);
    //context.read<ImsProvider>().ims.roomsList(streamController: streamController);
    return StreamBuilder(stream: streamController.stream, initialData: const {"APJ-01": {"Mon": ["03:00-04:00"]}}, builder: ((context, AsyncSnapshot<Map<String, Map<String, List<String>>>> snapshot) {
    
      if (snapshot.hasData) {
        return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: snapshot.data!.entries.map((entry) {
            return Card(
              child: Row(
                children: [
                  Text(entry.key),
                  Column(
                    children: entry.value['Mon']!.map((time) {
                      return Card(child: Text(time));
                      }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),  
        ),
      );
      } else {
        return const CircularProgressIndicator();
      }
      }
    ));
  }
}