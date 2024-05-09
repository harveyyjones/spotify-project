import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/screens/chat_screen.dart';
import 'package:spotify_project/widgets/bottom_bar.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

FirestoreDatabaseService firestoreDatabaseService = FirestoreDatabaseService();

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  void initState() {
    super.initState();

    print("initstate metodu tetiklendi.");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    firestoreDatabaseService.getUserDatasToMatch(
        firestoreDatabaseService.returnCurrentlyListeningMusicName(),
        SpotifySdk.isSpotifyAppActive,
        firestoreDatabaseService.returnCurrentlyListeningMusicName());
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    print("didChangeDependencies method triggered.");

    // Your initialization logic here
    await firestoreDatabaseService.getUserDatasToMatch(
      firestoreDatabaseService.returnCurrentlyListeningMusicName(),
      SpotifySdk.isSpotifyAppActive,
      firestoreDatabaseService.returnCurrentlyListeningMusicName(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(selectedIndex: 1),
      body: FutureBuilder(
          future: firestoreDatabaseService.getUserDataViaUId(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Container(
                color: Color.fromARGB(255, 234, 243, 252),
                child: Column(children: [
                  const SizedBox(
                    width: double.infinity,
                  ),
                  Container(
                    width: screenWidth - 30,
                    height: screenHeight /
                        (13 /
                            12), // Bu şekilde ondalık sayı yerine kesirli sayı kullanmanız sayıların değerlerini orantılı olarak yükselterek hassas ölçümler yapmanızı sağlar.
                    //  color: Colors.black,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(
                        height: screenHeight / 45,
                      ),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        // return index == 0
                        //     ? Column(
                        //         children: [
                        //           SizedBox(
                        //             width: double.infinity,
                        //             height: screenHeight / 15,
                        //           ),
                        //           Text(
                        //             "Something",
                        //             style: TextStyle(
                        //                 fontSize: 70.sp,
                        //                 fontWeight: FontWeight.w300),
                        //           ),
                        SizedBox(
                          height: screenHeight / 22,
                        );
                        //         ],
                        //       ):
                        return CardsForNotifications(
                          name: snapshot.data[index].name,
                          profilePhotoUrl: snapshot.data[index].profilePhotoURL,
                          index: index,
                          userId: snapshot.data[index].userId,
                        );
                      },
                    ),
                  ),
                ]),
              );
            } else {
              //TODO: Buralara daha güzel gözüken bir loading ekranı ayarlanacak.
              return Center(
                  child: CircularProgressIndicator(
                color: const Color.fromARGB(255, 168, 58, 58),
              ));
            }
          }),
    );
  }
}

class CardsForNotifications extends StatefulWidget {
  var name;
  var profilePhotoUrl;
  var index;
  String userId;
  CardsForNotifications({
    super.key,
    required this.name,
    required this.profilePhotoUrl,
    required this.index,
    required this.userId,
  });

  @override
  State<CardsForNotifications> createState() => _CardsFornyificationsState();
}

class _CardsFornyificationsState extends State<CardsForNotifications> {
  FirestoreDatabaseService _firestoreDatabaseService =
      FirestoreDatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firestoreDatabaseService.getTheMutualSongViaUId(widget.userId),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return InkWell(
            onTap: () => Navigator.of(context, rootNavigator: false)
                .push(MaterialPageRoute(
              builder: (context) => ChatScreen(
                  widget.userId, widget.profilePhotoUrl, widget.name),
            )),
            // onTap: () => Navigator.of(context).push(MaterialPageRoute(
            //   builder: (context) => ChatScreen(),
            // )),
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  offset: Offset(1, 2),
                  blurRadius: 1,
                  blurStyle: BlurStyle.outer,
                ),
              ], borderRadius: BorderRadius.circular(22), color: Colors.white),
              width: screenWidth / 1.1,
              height: screenHeight / 7,
              child: Row(
                children: [
                  SizedBox(
                    width: screenWidth / 33,
                  ),
                  CircleAvatar(
                      maxRadius: screenWidth / 11,
                      minRadius: 20,
                      backgroundImage: NetworkImage(widget.profilePhotoUrl)),
                  SizedBox(
                    width: screenWidth / 32,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: screenHeight / 55,
                      ),
                      Container(
                        width: screenWidth / 1.6,
                        height: screenHeight / 10,
                        color: Colors.white,
                        child: Text(
                          softWrap: true,
                          "You've listened \"${snapshot.data!.toString()} with ${widget.name} at the same time.",
                          style: TextStyle(fontSize: 33.sp, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
