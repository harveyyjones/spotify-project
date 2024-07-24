import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyServiceForTopArtists {
  final String accessToken;

  SpotifyServiceForTopArtists(this.accessToken);

  Future<SpotifyArtistsResponse> fetchArtists() async {
    String url = 'https://api.spotify.com/v1/me/top/artists?limit=10&offset=0';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return SpotifyArtistsResponse.fromJson(data);
    } else {
      throw Exception('Failed to fetch artists');
    }
  }
}

class SpotifyArtistsResponse {
  final String href;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;
  final List<Artist> items;

  SpotifyArtistsResponse({
    required this.href,
    required this.limit,
    this.next,
    required this.offset,
    this.previous,
    required this.total,
    required this.items,
  });

  factory SpotifyArtistsResponse.fromJson(Map<String, dynamic> json) {
    return SpotifyArtistsResponse(
      href: json['href'],
      limit: json['limit'],
      next: json['next'],
      offset: json['offset'],
      previous: json['previous'],
      total: json['total'],
      items:
          List<Artist>.from(json['items'].map((item) => Artist.fromJson(item))),
    );
  }
}

class Artist {
  final ExternalUrls externalUrls;
  final Followers followers;
  final List<String> genres;
  final String href;
  final String id;
  final List<ImageOftheArtist> images;
  final String name;
  final int popularity;
  final String type;
  final String uri;

  Artist({
    required this.externalUrls,
    required this.followers,
    required this.genres,
    required this.href,
    required this.id,
    required this.images,
    required this.name,
    required this.popularity,
    required this.type,
    required this.uri,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      followers: Followers.fromJson(json['followers']),
      genres: List<String>.from(json['genres']),
      href: json['href'],
      id: json['id'],
      images: List<ImageOftheArtist>.from(
          json['images'].map((image) => ImageOftheArtist.fromJson(image))),
      name: json['name'],
      popularity: json['popularity'],
      type: json['type'],
      uri: json['uri'],
    );
  }
}

class ExternalUrls {
  final String spotify;

  ExternalUrls({required this.spotify});

  factory ExternalUrls.fromJson(Map<String, dynamic> json) {
    return ExternalUrls(spotify: json['spotify']);
  }
}

class Followers {
  final String? href;
  final int total;

  Followers({this.href, required this.total});

  factory Followers.fromJson(Map<String, dynamic> json) {
    return Followers(
      href: json['href'],
      total: json['total'],
    );
  }
}

class ImageOftheArtist {
  final String url;
  final int height;
  final int width;

  ImageOftheArtist(
      {required this.url, required this.height, required this.width});

  factory ImageOftheArtist.fromJson(Map<String, dynamic> json) {
    return ImageOftheArtist(
      url: json['url'],
      height: json['height'],
      width: json['width'],
    );
  }
}
