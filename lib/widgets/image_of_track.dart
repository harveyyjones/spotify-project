import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_project/business/business_logic.dart';
import 'package:spotify_project/main.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class ImageOfTrack extends StatefulWidget {
  const ImageOfTrack({Key? key}) : super(key: key);

  @override
  State<ImageOfTrack> createState() => _ImageOfTrackState();
}

BusinessLogic _businessLogic = BusinessLogic();

class _ImageOfTrackState extends State<ImageOfTrack> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        var track = snapshot.data?.track;
        currentTrackImageUri = track?.imageUri;
        var playerState = snapshot.data;
        print(
            "**********************************************************************");
        print(currentTrackImageUri);

        if (playerState == null || track == null) {
          return Center(
            child: Container(),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20), // Add spacing
            connected
                ? FutureBuilder(
                    future: SpotifySdk.getImage(
                      imageUri: track.imageUri,
                      dimension: ImageDimension.large,
                    ),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<Uint8List?> snapshot,
                    ) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 11,
                          ),
                          child: Image.memory(snapshot.data!),
                        );
                      } else if (snapshot.hasError) {
                        _businessLogic.setStatus(snapshot.error.toString());
                        return SizedBox(
                          width: ImageDimension.large.value.toDouble(),
                          height: ImageDimension.large.value.toDouble(),
                          child:
                              const Center(child: Text('Error getting image')),
                        );
                      } else {
                        return SizedBox(
                          width: ImageDimension.large.value.toDouble(),
                          height: ImageDimension.large.value.toDouble(),
                          child: const Center(child: Text('Getting image...')),
                        );
                      }
                    },
                  )
                : const Text('Connect to see an image...'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 80,
                ),
                // Artist and track name
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
                      ),
                    ),
                    playerState.isPaused
                        ? IconButton(
                            onPressed: _businessLogic.resume,
                            icon: const Icon(
                              Icons.play_arrow,
                              weight: 50,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              _businessLogic.pause();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.pause,
                              weight: 50,
                            ),
                          ),
                    IconButton(
                      onPressed: _businessLogic.skipNext,
                      icon: const Icon(
                        Icons.skip_next,
                        weight: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
