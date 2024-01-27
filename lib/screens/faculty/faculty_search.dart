import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imsnsit/model/teacher.dart';
import 'package:imsnsit/provider/ims_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

class FacultySearch extends StatefulWidget {
  const FacultySearch({super.key});

  @override
  State<FacultySearch> createState() => _FacultySearchState();
}

class _FacultySearchState extends State<FacultySearch> {
  final TextEditingController _searchTextController = TextEditingController();
  late final ims = context.read<ImsProvider>().ims;
  final OverlayPortalController overlayPortalController =
      OverlayPortalController();
  late List<Teacher> searchResults = [];
  String selectedRadioButton = "EVEN";

  void searchFaculty() async {
    overlayPortalController.show();
    final String searchTerm = _searchTextController.text;

    if (searchTerm.isEmpty) {
      return;
    }

    searchResults =
        await ims.searchFaculty(searchTerm: _searchTextController.text);

    setState(() {
      searchResults;
    });
    overlayPortalController.hide();
  }

  Widget overlayChildBuilder(BuildContext ctx) {
    final baseColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(ctx).colorScheme.primary.withAlpha(150),
      child: Center(
          child: CircularProgressIndicator(
        color: baseColor,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Time Table"),
        centerTitle: true,
      ),
      body: OverlayPortal(
        controller: overlayPortalController,
        overlayChildBuilder: overlayChildBuilder,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          cursorColor:
                              Theme.of(context).colorScheme.onBackground,
                          controller: _searchTextController,
                          decoration: InputDecoration(
                              labelText: 'Search',
                              labelStyle: GoogleFonts.lexend(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(150),
                              isDense: true,
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)))),
                        ),
                      ),
                      IconButton(
                        onPressed: searchFaculty,
                        icon: const Icon(Icons.search),
                        style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(150),
                            shape: const CircleBorder()),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ListTile(
                            horizontalTitleGap: 0,
                            title: const Text('ODD'),
                            leading: Radio(
                              value: "ODD",
                              activeColor:
                                  Theme.of(context).colorScheme.onSurface,
                              groupValue: selectedRadioButton,
                              onChanged: (value) {
                                setState(() {
                                  selectedRadioButton = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            horizontalTitleGap: 0,
                            title: const Text('EVEN'),
                            leading: Radio(
                              value: "EVEN",
                              activeColor:
                                  Theme.of(context).colorScheme.onSurface,
                              groupValue: selectedRadioButton,
                              onChanged: (value) {
                                setState(() {
                                  selectedRadioButton = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ]),
                  FacultySearchResult(
                    searchResults: searchResults,
                    sem: selectedRadioButton,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FacultySearchResult extends StatelessWidget {
  const FacultySearchResult(
      {super.key, required this.searchResults, required this.sem});

  final List<Teacher> searchResults;
  final String sem;

  @override
  Widget build(BuildContext context) {
    int lastIndex = searchResults.length - 1;

    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        BorderRadiusGeometry borderRadius = BorderRadius.only(
          topLeft:
              index == 0 ? const Radius.circular(10) : const Radius.circular(0),
          topRight:
              index == 0 ? const Radius.circular(10) : const Radius.circular(0),
          bottomLeft: index == lastIndex
              ? const Radius.circular(10)
              : const Radius.circular(0),
          bottomRight: index == lastIndex
              ? const Radius.circular(10)
              : const Radius.circular(0),
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: ListTile(
            onTap: () =>
                context.pushNamed('faculty_time_table', pathParameters: {
              'tutor': searchResults[index].tutor,
              'tutorCode': searchResults[index].tutorCode,
              'sem': sem
            }),
            dense: true,
            leading: const Icon(Icons.person),
            title: Text(searchResults[index].tutor,
                style: GoogleFonts.lexend(fontSize: 15)),
            subtitle: Text(
              toBeginningOfSentenceCase(
                  searchResults[index].subject.toLowerCase()),
              style: GoogleFonts.lexend(fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
