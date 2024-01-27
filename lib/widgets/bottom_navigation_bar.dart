import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/provider/mode_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 1;
  late final prefs = context.read<SharedPreferences>();
  late List<int> disabledIndexes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (context.read<ModeProvider>().offline) {
      if (!prefs.containsKey("profileDataLastUpdated")) {
        disabledIndexes.add(0);
      }

      if (!prefs.containsKey("attendanceDataLastUpdated")) {
        disabledIndexes.add(1);
      }

      if (!prefs.containsKey("roomsDataLastUpdated")) {
        disabledIndexes.add(2);
      }
    }
  }

  void onItemTapped(int index) {
    if (!disabledIndexes.contains(index)) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 0) {
        context.go('/profile_screen');
      } else if (index == 1) {
        context.go('/attandance');
      } else if (index == 2) {
        context.go('/rooms');
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent),
          child: BottomNavigationBar(
            selectedItemColor:
                Theme.of(context).colorScheme.onSecondary.withAlpha(150),
            selectedLabelStyle: GoogleFonts.lexend(),
            unselectedItemColor: Theme.of(context).colorScheme.onBackground,
            unselectedLabelStyle: GoogleFonts.lexend(),
            selectedIconTheme: IconThemeData(
                color:
                    Theme.of(context).colorScheme.onSecondary.withAlpha(150)),
            unselectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.onBackground),
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 2,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.calendar_month,
                  ),
                  label: 'Attendance'),
              BottomNavigationBarItem(icon: Icon(Icons.laptop), label: 'APJ'),
            ],
            currentIndex: _selectedIndex,
            onTap: onItemTapped,
          ),
        ),
      ),
    );
  }
}
