import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotify_project/business/Spotify_Logic/constants.dart';

void fetchTracks() async {
  // Replace with your actual Spotify access token
  String accessToken = accesToken.toString();

  print("Show fetched tracks method called: $accessToken");

  final spotifyService = SpotifyService(accessToken);
  try {
    final data = await spotifyService.fetchTracks();
    for (var item in data) {
      printJson(item);
    }
  } catch (e) {
    print('Error: $e');
  }
}

void printJson(Map<String, dynamic> json) {
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(json));
}

class SpotifyService {
  final String accessToken;

  SpotifyService(this.accessToken);

  Future<List<Map<String, dynamic>>> fetchTracks() async {
    String? url = 'https://api.spotify.com/v1/me/tracks?limit=10';
    List<Map<String, dynamic>> allTracks = [];

    while (url != null) {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(data['items']);
        allTracks.addAll(items);

        url = data['next'] as String?;
      } else {
        throw Exception('Failed to fetch tracks');
      }
    }

    return allTracks;
  }
}
