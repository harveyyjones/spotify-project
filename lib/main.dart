import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/business/business_logic.dart';
import 'package:spotify_project/screens/landing_screen.dart';
import 'package:spotify_project/screens/steppers.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

FutureOr<User?> getCurrentUser() async {
  var currentUser = await FirebaseAuth.instance.currentUser;
  return currentUser;
}

FirestoreDatabaseService _databaseService = FirestoreDatabaseService();
String clientId = "b56ad9c2cf434b748466bb6adbb511ca";
String redirectURL = "https://www.rubycurehealthtourism.com/";
late ImageUri? currentTrackImageUri;
bool _loading = false;
late bool connected;
BusinessLogic _businessLogic = BusinessLogic();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAeu7KYeIdCUZ8DZ0oCjjzK15rVdilwKO8",
          appId: "1:985372741706:android:c92c014fe473d59aff96b3",
          messagingSenderId: "985372741706",
          projectId: "musee-285eb",
          storageBucket: "gs://musee-285eb.appspot.com"));
  try {
    await SpotifySdk.connectToSpotifyRemote(
            clientId: clientId, redirectUrl: redirectURL)
        .then((value) => runApp(const MyApp()));
  } catch (e) {
    print("Spotify girişe izin vermedi.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(720, 1080),
        builder: (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Rubycure',
            home: FutureBuilder<User?>(
                future: Future.value(getCurrentUser()),
                builder: (BuildContext context,
                    AsyncSnapshot<FutureOr<User?>> snapshot) {
                  if (snapshot.hasData) {
                    FutureOr<User?>? user =
                        snapshot.data; // bu senin kullanıcı örneğin.
                    /// burada kullanıcı oturum açmış.
                    print(
                        "************************************************************");
                    print("Şu anda bir oturum açık: ${currentUser?.uid}");

                    return LandingPage();
                  } else {
                    return LandingPage();
                  }

                  /// kullanıcı oturum açmamış.
                })));
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    _businessLogic.connectToSpotifyRemote();
    _businessLogic.getAccessToken(clientId, redirectURL);

    super.initState();
  }

  final Logger _logger = Logger(
    //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true,
    ),
  );

  @override
  Widget build(BuildContext context1) {
    return MaterialApp(
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          connected = false;
          var data = snapshot.data;
          if (data != null) {
            connected = data.connected;
          }
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                    label: "My Profile", icon: Icon(Icons.person)),
                BottomNavigationBarItem(
                    label: "Messages", icon: Icon(Icons.message))
              ],
            ),
            body: Everything(connected),
            // bottomNavigationBar: _connected ? _buildBottomBar(context) : null,
          );
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class Everything extends StatefulWidget {
  bool connected;
  Everything(this.connected, {super.key});

  @override
  State<Everything> createState() => _EverythingState();
}

class _EverythingState extends State<Everything> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color.fromARGB(255, 176, 255, 233),
        ),
        ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    _businessLogic.connectToSpotifyRemote();
                  },
                  child: const Icon(Icons.settings_remote),
                ),
              ],
            ),
            widget.connected
                ? StreamBuilder<PlayerState>(
                    stream: SpotifySdk.subscribePlayerState(),
                    builder: (BuildContext context,
                        AsyncSnapshot<PlayerState> snapshot) {
                      var track = snapshot.data?.track;
                      currentTrackImageUri = track?.imageUri;
                      var playerState = snapshot.data;

                      if (playerState == null || track == null) {
                        return Center(
                          child: Container(color: Colors.purple),
                        );
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // PLAYBACK DAKIKASI BURDA
                              // Text(
                              //     'Progress: ${playerState.playbackPosition}ms/${track.duration}ms'),
                            ],
                          ),
                          widget.connected
                              ? FutureBuilder(
                                  future: SpotifySdk.getImage(
                                    imageUri: track.imageUri,
                                    dimension: ImageDimension.large,
                                  ),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Uint8List?> snapshot) {
                                    // ******************************************* IMAGE IS HERE ***************************************
                                    if (snapshot.hasData) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                11),
                                        child: Image.memory(snapshot.data!),
                                      );
                                    } else if (snapshot.hasError) {
                                      _businessLogic
                                          .setStatus(snapshot.error.toString());
                                      return SizedBox(
                                        width: ImageDimension.large.value
                                            .toDouble(),
                                        height: ImageDimension.large.value
                                            .toDouble(),
                                        child: const Center(
                                            child: Text('Error getting image')),
                                      );
                                    } else {
                                      return SizedBox(
                                        width: ImageDimension.large.value
                                            .toDouble(),
                                        height: ImageDimension.large.value
                                            .toDouble(),
                                        child: const Center(
                                            child: Text('Getting image...')),
                                      );
                                    }
                                  })
                              : const Text('Connect to see an image...'),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 80,
                              ),

                              // ********************************* ŞARKI VE SANATÇI İSMİ *************************************************
                              Text(
                                '${track.artist.name} - ${track.name} ',
                                style: const TextStyle(fontSize: 22),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  IconButton(
                                      onPressed: _businessLogic.skipPrevious,
                                      icon: const Icon(
                                        Icons.skip_previous,
                                        weight: 50,
                                      )),
                                  playerState.isPaused
                                      ? IconButton(
                                          onPressed: _businessLogic.resume,
                                          icon: const Icon(
                                            Icons.play_arrow,
                                            weight: 50,
                                          ))
                                      : IconButton(
                                          onPressed: () {
                                            _businessLogic.pause();
                                            setState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.pause,
                                            weight: 50,
                                          )),
                                  IconButton(
                                      onPressed: _businessLogic.skipNext,
                                      icon: const Icon(
                                        Icons.skip_next,
                                        weight: 50,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  )
                : const Center(
                    child: Text('Not connected'),
                  ),
          ],
        ),
        _loading
            ? Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()))
            : const SizedBox(),
      ],
    );
  }
}
