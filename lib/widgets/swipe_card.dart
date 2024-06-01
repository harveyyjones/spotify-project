import 'package:flutter/material.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/screens/matches_screen.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';

class SwipeCardWidget extends StatefulWidget {
  SwipeCardWidget({
    Key? key,
    this.title = "Anan;",
    this.userCard,
    this.snapshotData,
  }) : super(key: key);
  Widget? userCard;
  final String? title;
  var snapshotData;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SwipeCardWidget> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    for (var i = 0; i < widget.snapshotData.length; i++) {
      _swipeItems.add(SwipeItem(likeAction: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Liked"),
          duration: Duration(milliseconds: 500),
        ));
      }, nopeAction: () {
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
          color: Colors.amber,
          child: Stack(children: [
            Container(
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              child: SwipeCards(
                matchEngine: _matchEngine!,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.snapshotData[index].name,
                      style: TextStyle(fontSize: 100),
                    ),
                  );
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
                children: [
                  ElevatedButton(
                      onPressed: () {
                        _matchEngine!.currentItem?.nope();
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
                      },
                      child: const Text("Like"))
                ],
              ),
            )
          ]),
        ));
  }
}
