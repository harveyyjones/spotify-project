// services/spotify_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotify_project/business/Spotify_Logic/Models/top_10_track_model.dart';

class SpotifyServiceForTracks {
  final String accessToken;

  SpotifyServiceForTracks(this.accessToken);

  Future<List<SpotifyTrack>> fetchTracks() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/top/tracks'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['items'];
      return data.map((track) => SpotifyTrack.fromJson(track)).toList();
    } else {
      throw Exception('Failed to load top tracks');
    }
  }
}
