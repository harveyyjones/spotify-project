import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotify_project/business/Spotify_Logic/Models/top_playlists.dart';
import 'package:spotify_project/business/Spotify_Logic/constants.dart';

class SpotifyServiceForPlaylists {
  String accessToken;
  SpotifyServiceForPlaylists(this.accessToken);

  Future<List<Playlist>> fetchPlaylists() async {
    print('Fetching playlists from Spotify...');
    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/browse/featured-playlists?locale=pl_PL&limit=6&offset=0'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print('Data decoded successfully');
      List<dynamic> playlists = data['playlists']['items'];
      print('Playlists parsed: ${playlists.length}');
      List<Playlist> fetchedPlaylists =
          playlists.map((item) => Playlist.fromJson(item)).toList();
      print('Fetched ${fetchedPlaylists.length} playlists');
      return fetchedPlaylists;
    } else {
      print(
          'Failed to load top playlists. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load top playlists');
    }
  }
}
