import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_project/business/business_logic.dart';
import 'package:spotify_project/main.dart';
import 'package:spotify_project/widgets/image_of_track.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen();

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

BusinessLogic _businessLogic = BusinessLogic();

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  bool _loading = false;
  bool _connected = false;
  final double _sliderDurationMusic = 50.0;
  double _sliderVolume = 0.5;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                ? StreamBuilder<PlayerState>(
                    stream: SpotifySdk.subscribePlayerState(),
                    builder: (BuildContext context,
                        AsyncSnapshot<PlayerState> snapshot) {
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
                              ? ImageOfTrack()
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
                    child: Text('Not connectedd!'),
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
