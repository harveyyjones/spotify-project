import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/screens/matches_screen.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';

class SwipeCardWidget extends StatefulWidget {
  SwipeCardWidget({
    Key? key,
    this.title = "Your matches.",
    this.userCard,
    this.snapshotData,
  }) : super(key: key);
  Widget? userCard;
  final String? title;
  var snapshotData;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

FirestoreDatabaseService _firestoreDatabaseService = FirestoreDatabaseService();

class _MyHomePageState extends State<SwipeCardWidget> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    for (var i = 0; i < widget.snapshotData.length; i++) {
      _swipeItems.add(SwipeItem(likeAction: () {
        _firestoreDatabaseService.updateIsLiked(
            true, widget.snapshotData[i].userId);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color.fromARGB(255, 9, 184, 178),
          content: Text("Liked"),
          duration: Duration(milliseconds: 500),
        ));
      }, nopeAction: () {
        _firestoreDatabaseService.updateIsLiked(
            false, widget.snapshotData[i].userId);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Nope"),
          duration: Duration(milliseconds: 500),
        ));
      }, superlikeAction: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Superliked"),
          duration: Duration(milliseconds: 500),
        ));
      }, onSlideUpdate: (SlideRegion? region) async {
        print("Region $region");
      }));
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: Container(
          width: screenWidth,
          height: screenHeight,
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Stack(children: [
            Container(
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              child: SwipeCards(
                matchEngine: _matchEngine!,
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder(
                      future: _firestoreDatabaseService.getTheMutualSongViaUId(
                          widget.snapshotData[index].userId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(children: [
                            Container(
                              height: screenHeight,
                              width: screenWidth,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              alignment: Alignment.center,
                              child: Image(
                                  width: screenWidth,
                                  height: screenHeight,
                                  fit: BoxFit.cover,
                                  image: NetworkImage(widget
                                      .snapshotData[index].profilePhotoURL)),
                            ),
                            Positioned(
                              left: screenWidth / 11,
                              bottom: screenHeight / 12,
                              child: Row(
                                children: [
                                  Text(
                                    widget.snapshotData[index].name,
                                    style: GoogleFonts.alata(
                                      textStyle: TextStyle(
                                          fontSize: 55.sp,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          letterSpacing: .5),
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth / 7,
                                  ),
                                  Text(
                                    softWrap: true,
                                    "You've listened \"${snapshot.data!.toString()} with ${widget.snapshotData[index].name} at the same time.",
                                    style: GoogleFonts.alata(
                                      textStyle: TextStyle(
                                          fontSize: 15.sp,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          letterSpacing: .5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      });
                },
                onStackFinished: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Stack Finished"),
                    duration: Duration(milliseconds: 500),
                  ));
                },
                itemChanged: (SwipeItem item, int index) {
                  // print("item: ${item.content.text}, index: $index");
                },
                leftSwipeAllowed: true,
                rightSwipeAllowed: true,
                upSwipeAllowed: true,
                fillSpace: true,
                likeTag: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.green)),
                  child: const Text('Like'),
                ),
                nopeTag: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.red)),
                  child: const Text('Nope'),
                ),
                superLikeTag: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.orange)),
                  child: const Text('Super Like'),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // ************************* LIKE OR DISLIKE BUTTONS ********************************
                children: [
                  ElevatedButton(
                      onPressed: () {
                        _matchEngine!.currentItem?.nope();
                        // _firestoreDatabaseService.updateIsLiked(false,
                        //     widget.snapshotData[_matchEngine!.currentItem!._].uid);
                        print(_matchEngine!.currentItem?.content.toString());
                      },
                      child: const Text("Nope")),
                  ElevatedButton(
                      onPressed: () {
                        _matchEngine!.currentItem?.superLike();
                      },
                      child: const Text("Superlike")),
                  ElevatedButton(
                      onPressed: () {
                        _matchEngine!.currentItem?.like();
                        // _firestoreDatabaseService.updateIsLiked(true,
                        //     widget.snapshotData[_matchEngine?.currentItem].uid);
                      },
                      child: const Text("Like"))
                ],
              ),
            )
          ]),
        ));
  }
}
