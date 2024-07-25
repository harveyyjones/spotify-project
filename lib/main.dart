import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/business/Spotify_Logic/constants.dart';
import 'package:spotify_project/business/Spotify_Logic/Models/top_playlists.dart';
import 'package:spotify_project/business/Spotify_Logic/services/fetch_playlists.dart';
import 'package:spotify_project/business/business_logic.dart';
import 'package:spotify_project/screens/landing_screen.dart';
import 'package:spotify_project/widgets/bottom_bar.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'screens/quick_match_screen.dart';

FutureOr<User?> getCurrentUser() async {
  var currentUser = FirebaseAuth.instance.currentUser;
  return currentUser;
}

FirestoreDatabaseService _service = FirestoreDatabaseService();
String clientId = "b56ad9c2cf434b748466bb6adbb511ca";
String redirectURL = "https://www.rubycurehealthtourism.com/";
late ImageUri? currentTrackImageUri;
bool _loading = false;
bool connected = false;
BusinessLogic _businessLogic = BusinessLogic();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAeu7KYeIdCUZ8DZ0oCjjzK15rVdilwKO8",
          appId: "1:985372741706:android:c92c014fe473d59aff96b3",
          messagingSenderId: "985372741706",
          projectId: "musee-285eb",
          storageBucket: "gs://musee-285eb.appspot.com"));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(720, 1080),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Musee',
        home: FutureBuilder<User?>(
          future: Future.value(getCurrentUser()),
          builder:
              (BuildContext context, AsyncSnapshot<FutureOr<User?>> snapshot) {
            if (snapshot.hasData) {
              var user = snapshot.data; // bu senin kullanıcı örneğin.
              print(
                  "************************************************************");
              print("Şu anda bir oturum açık.");

              return Home();
            } else {
              return LandingPage();
            }
          },
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  handleAuthAndTokenForSpotify() async {
    await _businessLogic.getAccessToken(clientId, redirectURL).then((value) =>
        _businessLogic
            .connectToSpotifyRemote()
            .then((value) => connected = true));
  }

  late final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  @override
  void initState() {
    if (connected == true) {
      return;
    } else {
      handleAuthAndTokenForSpotify();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          var data = snapshot.data;
          if (data != null) {
            connected = data.connected;
            print(
                "************** Is connected? :  ${connected} *******************");
          }
          return Scaffold(
            bottomNavigationBar: BottomBar(selectedIndex: 0),
            body: Everything(connected),
          );
        },
      ),
    );
  }
}

class Everything extends StatefulWidget {
  final bool connected;
  const Everything(this.connected, {Key? key}) : super(key: key);

  @override
  State<Everything> createState() => _EverythingState();
}

class _EverythingState extends State<Everything> {
  late StreamSubscription<bool> _subscription;
  late Timer _timer;

  bool _loading = false;
  late Future<List<Playlist>> futurePlaylists;

  @override
  Future<List<Playlist>> fetchPlaylists() async {
    SpotifyServiceForPlaylists spotifyService = SpotifyServiceForPlaylists(
        accessToken); // Replace with your actual token
    return await spotifyService.fetchPlaylists();
  }

  void initState() {
    super.initState();
    futurePlaylists = fetchPlaylists();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startTimer({name}) {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      firestoreDatabaseService.updateActiveStatus(snapshot: name);
    });
  }

  void callSetState() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color.fromARGB(255, 234, 243, 252),
        ),
        ListView(
          padding: const EdgeInsets.all(8),
          children: [
            SizedBox(
              height: screenHeight / 15,
              // *********************** QUICK MATCH BUTTON ********************
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QuickMatchesScreen()));
              },
              child: Padding(
                padding: EdgeInsets.only(
                    left: screenWidth / 20, right: screenWidth / 20),
                child: Container(
                  width: screenWidth / 1.5,
                  height: screenHeight / 10,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(21)),
                      color: Color.fromARGB(255, 92, 190, 214),
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
                    "Quick Match",
                    style: GoogleFonts.alata(
                      textStyle: TextStyle(
                          fontSize: 48.sp,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          letterSpacing: .5),
                    ),
                  )),
                ),
              ),
            ),
            widget.connected
                ? StreamBuilder<PlayerState>(
                    stream: SpotifySdk.subscribePlayerState(),
                    builder: (BuildContext context,
                        AsyncSnapshot<PlayerState> snapshot) {
                      var track = snapshot.data?.track;
                      currentTrackImageUri = track?.imageUri;
                      var playerState = snapshot.data;
                      firestoreDatabaseService.updateActiveStatus();

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasData) {
                        return Column(
                          children: <Widget>[
                            SizedBox(
                              height: screenHeight / 600,
                            ),
                            Text(
                              '${snapshot.data!.track!.artist.name} - ${snapshot.data!.track!.name} ',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ],
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : const Center(
                    child: Text('Not connected'),
                  ),
            // ******************************  PLAYLISTS **************************
            FutureBuilder<List<Playlist>>(
              future: futurePlaylists,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No playlists found'));
                } else {
                  final playlists = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        leading: playlist.images.isNotEmpty
                            ? Image.network(playlist.images.first.url)
                            : null,
                        title: Text(playlist.name),
                        subtitle: Text(playlist.description),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
        _loading
            ? Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              )
            : const SizedBox(),
      ],
    );
  }
}
