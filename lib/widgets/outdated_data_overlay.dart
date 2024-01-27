import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

Widget outdatedDataOverlay(BuildContext context,
    {required String? lastUpdated, required void Function() action}) {
  return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          color: Colors.red.withAlpha(200),
          child: ListTile(
            minVerticalPadding: 22,
            title: Text(
              "Last Updated: $lastUpdated",
              style: GoogleFonts.lexend(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            trailing: IconButton(
                onPressed: action,
                icon: Icon(
                  Icons.refresh,
                  size: 20,
                  color: Colors.black87,
                )),
          ),
        ),
      ));
}
