import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/screens/chat_screen.dart';
import 'package:spotify_project/screens/matches_screen.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';

class SwipeCardWidget extends StatefulWidget {
  SwipeCardWidget({
    Key? key,
    this.title = "You have similar music taste with these people.",
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
    widget.snapshotData.shuffle();
    for (var i = 0; i < widget.snapshotData.length; i++) {
      _swipeItems.add(SwipeItem(likeAction: () {
        _firestoreDatabaseService.updateIsLiked(
            true, widget.snapshotData[i].userId);
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => ChatScreen(
              widget.snapshotData[i].userId,
              widget.snapshotData[i].profilePhotoURL,
              widget.snapshotData[i].name),
        ));

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
          title: Text(
            widget.title.toString(),
            style: GoogleFonts.alata(
              textStyle: TextStyle(
                  fontSize: 27.sp,
                  color: Color.fromARGB(255, 0, 0, 0),
                  letterSpacing: .5),
            ),
          ),
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
                          image: NetworkImage(
                              widget.snapshotData[index].profilePhotoURL)),
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
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  letterSpacing: .5),
                            ),
                          ),
                          SizedBox(
                            width: screenWidth / 11,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight / 25),
                            child: Container(
                              width: screenWidth / 2,
                              color: const Color.fromARGB(0, 255, 193, 7),
                              child: Text(
                                softWrap: true,
                                overflow: TextOverflow.clip,
                                "${widget.snapshotData[index].biography}",
                                style: GoogleFonts.alata(
                                  textStyle: TextStyle(
                                      fontSize: 30.sp,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      letterSpacing: .5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]);
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
                upSwipeAllowed: false,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // ************************* LIKE OR DISLIKE BUTTONS ********************************
                    children: [
                      GestureDetector(
                        onTap: () {
                          _matchEngine!.currentItem?.nope();
                        },
                        child: Container(
                          width: screenWidth / 5,
                          height: screenHeight / 20,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(21)),
                              color: Color.fromARGB(255, 255, 0, 0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(66, 66, 66, 0.244),
                                    spreadRadius: 1,
                                    offset: Offset(
                                      2,
                                      10,
                                    ),
                                    blurRadius: 10)
                              ]),
                          child: Center(
                              child: Text(
                            "Nope",
                            style: GoogleFonts.alata(
                              textStyle: TextStyle(
                                  fontSize: 25.sp,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  letterSpacing: .5),
                            ),
                          )),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _matchEngine!.currentItem?.like();
                        },
                        child: Container(
                          width: screenWidth / 5,
                          height: screenHeight / 20,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(21)),
                              color: Color.fromARGB(255, 58, 215, 49),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(66, 66, 66, 0.244),
                                    spreadRadius: 1,
                                    offset: Offset(
                                      2,
                                      10,
                                    ),
                                    blurRadius: 10)
                              ]),
                          child: Center(
                              child: Text(
                            "Like",
                            style: GoogleFonts.alata(
                              textStyle: TextStyle(
                                  fontSize: 25.sp,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  letterSpacing: .5),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight / 60,
                  )
                ],
              ),
            )
          ]),
        ));
  }
}
