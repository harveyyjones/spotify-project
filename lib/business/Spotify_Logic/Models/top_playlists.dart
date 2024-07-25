// models/top_playlists.dart
class ExternalUrls {
  final String spotify;

  ExternalUrls({required this.spotify});

  factory ExternalUrls.fromJson(Map<String, dynamic> json) {
    return ExternalUrls(spotify: json['spotify']);
  }

  Map<String, dynamic> toJson() {
    return {
      'spotify': spotify,
    };
  }
}

class Owner {
  final String displayName;
  final ExternalUrls externalUrls;
  final String href;
  final String id;

  Owner({
    required this.displayName,
    required this.externalUrls,
    required this.href,
    required this.id,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      displayName: json['display_name'],
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      href: json['href'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'external_urls': externalUrls.toJson(),
      'href': href,
      'id': id,
    };
  }
}

class ImageOfThePlaylists {
  final int? height;
  final String url;
  final int? width;

  ImageOfThePlaylists({this.height, required this.url, this.width});

  factory ImageOfThePlaylists.fromJson(Map<String, dynamic> json) {
    return ImageOfThePlaylists(
      height: json['height'],
      url: json['url'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'url': url,
      'width': width,
    };
  }
}

class Tracks {
  final String href;
  final int total;

  Tracks({required this.href, required this.total});

  factory Tracks.fromJson(Map<String, dynamic> json) {
    return Tracks(
      href: json['href'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'href': href,
      'total': total,
    };
  }
}

class Playlist {
  final String id;
  final String name;
  final String description;
  final ExternalUrls externalUrls;
  final Owner owner;
  final List<ImageOfThePlaylists> images;
  final Tracks tracks;
  final String href;
  final String type;
  final bool collaborative;
  final bool public;
  final String snapshotId;
  final String uri;
  final String primaryColor;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.externalUrls,
    required this.owner,
    required this.images,
    required this.tracks,
    required this.href,
    required this.type,
    required this.collaborative,
    required this.public,
    required this.snapshotId,
    required this.uri,
    required this.primaryColor,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      externalUrls: ExternalUrls.fromJson(json['external_urls']),
      owner: Owner.fromJson(json['owner']),
      images: (json['images'] as List)
          .map((i) => ImageOfThePlaylists.fromJson(i))
          .toList(),
      tracks: Tracks.fromJson(json['tracks']),
      href: json['href'],
      type: json['type'],
      collaborative: json['collaborative'],
      public: json['public'],
      snapshotId: json['snapshot_id'],
      uri: json['uri'],
      primaryColor: json['primary_color'] ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'external_urls': externalUrls.toJson(),
      'owner': owner.toJson(),
      'images': images.map((i) => i.toJson()).toList(),
      'tracks': tracks.toJson(),
      'href': href,
      'type': type,
      'collaborative': collaborative,
      'public': public,
      'snapshot_id': snapshotId,
      'uri': uri,
      'primary_color': primaryColor,
    };
  }
}
