import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
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
      body: Flex(direction: Axis.vertical, children: [
        const SizedBox(
          height: 6,
        ),
        Expanded(
          // Change the children to stream builder if neccesary
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Card(
                    margin: const EdgeInsets.all(2),
                    elevation: 20,
                    child: GestureDetector(
                      onTap: () {
                        // ACTION HERE
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Image(
                          image: NetworkImage("https://picsum.photos/200/300"),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ]),
    );
  }
}
