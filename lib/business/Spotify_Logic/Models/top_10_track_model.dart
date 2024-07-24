class SpotifyTrack {
  final String id;
  final String name;
  final List<Artist> artists;
  final Album album;
  final String previewUrl;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.previewUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id'] as String,
      name: json['name'] as String,
      artists: (json['artists'] as List)
          .map((artist) => Artist.fromJson(artist))
          .toList(),
      album: Album.fromJson(json['album']),
      previewUrl: json['preview_url'] ?? '', // Handle null preview_url
    );
  }
}

class Artist {
  final String id;
  final String name;
  final String href;

  Artist({
    required this.id,
    required this.name,
    required this.href,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as String,
      name: json['name'] as String,
      href: json['href'] as String,
    );
  }
}

class Album {
  final String id;
  final String name;
  final List<ImageOfTheTrack> images;

  Album({
    required this.id,
    required this.name,
    required this.images,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      name: json['name'] as String,
      images: (json['images'] as List)
          .map((image) => ImageOfTheTrack.fromJson(image))
          .toList(),
    );
  }
}

class ImageOfTheTrack {
  final int height;
  final String url;
  final int width;

  ImageOfTheTrack({
    required this.height,
    required this.url,
    required this.width,
  });

  factory ImageOfTheTrack.fromJson(Map<String, dynamic> json) {
    return ImageOfTheTrack(
      height: json['height'] as int,
      url: json['url'] as String,
      width: json['width'] as int,
    );
  }
}
