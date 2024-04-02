import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:spotify_project/business/business_logic.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

String clientId = "b56ad9c2cf434b748466bb6adbb511ca";
String redirectURL = "https://www.rubycurehealthtourism.com/";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SpotifySdk.connectToSpotifyRemote(
            clientId: clientId, redirectUrl: redirectURL)
        .then((value) => runApp(const Home()));
  } catch (e) {
    print("Spotify girişe izin vermedi.");
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    connectToSpotifyRemote();
    _businessLogic.getAccessToken(clientId, redirectURL);

    super.initState();
  }

  bool _loading = false;
  bool _connected = false;
  final double _sliderDurationMusic = 50.0;
  double _sliderVolume = 0.5;

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

  CrossfadeState? crossfadeState;
  late ImageUri? currentTrackImageUri;
  BusinessLogic _businessLogic = BusinessLogic();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          _connected = false;
          var data = snapshot.data;
          if (data != null) {
            _connected = data.connected;
          }
          return Scaffold(
            body: mainScreen(context),
            // bottomNavigationBar: _connected ? _buildBottomBar(context) : null,
          );
        },
      ),
    );
  }

// BODY OF THE APPLICATION
  Widget mainScreen(BuildContext context2) {
    return Stack(
      children: [
        Container(
          color: Color.fromARGB(255, 176, 255, 233),
        ),
        ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: connectToSpotifyRemote,
                  child: const Icon(Icons.settings_remote),
                ),
              ],
            ),
            _connected
                ? homeScreenWidget()
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

  Widget homeScreenWidget() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        var track = snapshot.data?.track;
        currentTrackImageUri = track?.imageUri;

        var playerState = snapshot.data;

        if (playerState == null || track == null) {
          return Center(
            child: Container(),
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
            _connected
                ? spotifyImageWidget(track.imageUri)
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
                  style: TextStyle(fontSize: 22),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );
  }

  Widget _buildPlayerContextWidget() {
    return StreamBuilder<PlayerContext>(
      stream: SpotifySdk.subscribePlayerContext(),
      initialData: PlayerContext('', '', '', ''),
      builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
        var playerContext = snapshot.data;
        if (playerContext == null) {
          return const Center(
            child: Text('Not connected'),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget spotifyImageWidget(ImageUri image) {
    return FutureBuilder(
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.large,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 11),
              child: Image.memory(snapshot.data!),
            );
          } else if (snapshot.hasError) {
            _businessLogic.setStatus(snapshot.error.toString());
            return SizedBox(
              width: ImageDimension.large.value.toDouble(),
              height: ImageDimension.large.value.toDouble(),
              child: const Center(child: Text('Error getting image')),
            );
          } else {
            return SizedBox(
              width: ImageDimension.large.value.toDouble(),
              height: ImageDimension.large.value.toDouble(),
              child: const Center(child: Text('Getting image...')),
            );
          }
        });
  }

  //********************************************************** AŞAĞISI YALNIZCA BUSINESS LOGIC.  ***************************************************************** */

  // Hesapla bağlantıyı ve senkronizasyonu kesen fonksiyon.
  Future<void> disconnect() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.disconnect();
      _businessLogic
          .setStatus(result ? 'disconnect successful' : 'disconnect failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      _businessLogic.setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      _businessLogic.setStatus('not implemented');
    }
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: clientId, redirectUrl: redirectURL);
      _businessLogic.setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      _businessLogic.setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      _businessLogic.setStatus('not implemented');
    }
  }
}

class Everything extends StatefulWidget {
  const Everything({super.key});

  @override
  State<Everything> createState() => _EverythingState();
}

class _EverythingState extends State<Everything> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
