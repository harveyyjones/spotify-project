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
import 'package:spotify_project/screens/matches_screen.dart';
import 'package:spotify_project/widgets/bottom_bar.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

FutureOr<User?> getCurrentUser() async {
  var currentUser = FirebaseAuth.instance.currentUser;
  return currentUser;
}

FirestoreDatabaseService _service = FirestoreDatabaseService();
String clientId = "b56ad9c2cf434b748466bb6adbb511ca";
String redirectURL = "https://www.rubycurehealthtourism.com/";
late ImageUri? currentTrackImageUri;
bool _loading = false;
late bool connected;
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

  try {
    await SpotifySdk.connectToSpotifyRemote(
      clientId: clientId,
      redirectUrl: redirectURL,
    ).then((value) => runApp(const MyApp()));
  } catch (e) {
    print("Spotify girişe izin vermedi.");
  }
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

              return const Home();
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
    await _businessLogic
        .connectToSpotifyRemote()
        .then((value) => connected = true);
    await _businessLogic.getAccessToken(clientId, redirectURL);
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
    // _businessLogic.connectToSpotifyRemote().then((value) => connected = true);
    // _businessLogic.getAccessToken(clientId, redirectURL);

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    connected = false;
  }

  @override
  Widget build(BuildContext context) {
    handleAuthAndTokenForSpotify();
    return MaterialApp(
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          connected = false;
          var data = snapshot.data;
          if (data != null) {
            connected = data.connected;
            print(
                "************** Is connected? :  ${connected} *******************");
          }
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () async {
                    await _service.signOut(context);
                    Navigator.pushAndRemoveUntil<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) => LandingPage(),
                      ),
                      (route) => true,
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
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
  late bool isActive; // isActive değişkeni tanımlandı
  late StreamSubscription<bool> _subscription;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateActiveStatus();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _startTimer();
    _updateActiveStatus();
  }

  void _startTimer({name}) {
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _updateActiveStatus(name: name);
    });
  }

  void callSetState() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {});
    });
  }

  void _updateActiveStatus({name}) async {
    try {
      isActive = await SpotifySdk.isSpotifyAppActive;

      var _name = SpotifySdk.subscribePlayerState();

      _name.listen((event) async {
        print("*****************************************************");
        print(isActive);
        print(event.track?.name ?? "");
        _name != null
            ? _service.updateIsUserListening(isActive, event.track!.name)
            : _service.updateIsUserListening(isActive, "");

        firestoreDatabaseService.getUserDatasToMatch(
            event.track?.name, isActive, event.track?.name);
      });
    } catch (e) {
      print("Spotify is not active or disconnected: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // callSetState();
    return Stack(
      children: [
        Container(
          color: const Color.fromARGB(255, 139, 204, 182),
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
                      _startTimer();

                      if (playerState == null || track == null) {
                        return Center(
                          child: Container(color: Colors.purple),
                        );
                      } else {
//TODO: Aşağıya bir şekilde stream entegre et.
                        return Column(
                          children: <Widget>[
                            FutureBuilder(
                              future: SpotifySdk.getImage(
                                imageUri: track.imageUri,
                                dimension: ImageDimension.large,
                              ),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Uint8List?> snapshot) {
                                if (snapshot.hasData) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height /
                                                11),
                                    child: Image.memory(snapshot.data!),
                                  );
                                } else {
                                  return Center(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.amber,
                                    ),
                                  );
                                }
                              },
                            ),
                            Text(
                              '${track.artist.name} - ${track.name} ',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ],
                        );
                      }
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
                child: const Center(child: CircularProgressIndicator()),
              )
            : const SizedBox(),
      ],
    );
  }
}
