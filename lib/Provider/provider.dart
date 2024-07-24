import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class PlayerStateNotifier extends ChangeNotifier {
  PlayerState? _playerState;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  PlayerStateNotifier() {
    _initializeStream();
  }

  PlayerState? get playerState => _playerState;

  void _initializeStream() {
    try {
      _playerStateSubscription =
          SpotifySdk.subscribePlayerState().listen((PlayerState event) {
        _playerState = event;
        notifyListeners();
      });
    } catch (e) {
      print('Error initializing stream: $e');
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    super.dispose();
  }
}
