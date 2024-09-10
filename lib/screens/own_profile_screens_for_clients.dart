import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/business/Spotify_Logic/Models/top_10_track_model.dart';
import 'package:spotify_project/business/Spotify_Logic/constants.dart';
import 'package:spotify_project/business/Spotify_Logic/services/fetch_artists.dart';
import 'package:spotify_project/business/Spotify_Logic/services/fetch_top_10_tracks_of_the_user.dart';
import 'package:spotify_project/screens/profile_settings.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/widgets/bottom_bar.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnProfileScreenForClients extends StatefulWidget {
  OwnProfileScreenForClients({Key? key}) : super(key: key);

  @override
  State<OwnProfileScreenForClients> createState() =>
      _OwnProfileScreenForClientsState();
}

class _OwnProfileScreenForClientsState
    extends State<OwnProfileScreenForClients> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  final FirestoreDatabaseService _serviceForSnapshot =
      FirestoreDatabaseService();
  late Future<Map<String, dynamic>> _combinedFuture;
  Map<String, dynamic>? _cachedData;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _combinedFuture = _loadAllData();
  }

  Future<Map<String, dynamic>> _loadAllData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    final userData = await _serviceForSnapshot.getUserData();
    final artists = await SpotifyServiceForTopArtists(accessToken).fetchArtists();
    final tracks = await SpotifyServiceForTracks(accessToken).fetchTracks();

    _cachedData = {
      'userData': userData,
      'artists': artists,
      'tracks': tracks,
    };

    return _cachedData!;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _combinedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.yellow));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
        }

        final data = snapshot.data!;
        final userData = data['userData'];
        final artists = data['artists'] as SpotifyArtistsResponse;
        final tracks = data['tracks'] as List<SpotifyTrack>;

        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildUserProfile(userData)),
              // SliverToBoxAdapter(child: _buildCurrentTrack()),
              SliverToBoxAdapter(child: _buildTopArtists(artists)),
              SliverToBoxAdapter(child: Divider(thickness: 1, color: Colors.yellow.withOpacity(0.5))),
              SliverToBoxAdapter(child: _buildTopTracks(tracks)),
            ],
          ),
          bottomNavigationBar: BottomBar(
            selectedIndex: userData.clinicOwner ?? true ? 2 : 2,
          ),
        );
      },
    );
  }

  Widget _buildUserProfile(dynamic userData) {
    List<String> profilePhotos = userData.profilePhotos ?? [];
    String defaultImage = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
    
    if (profilePhotos.isEmpty) {
      profilePhotos = [defaultImage];
    }

    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: PageView.builder(
            controller: _pageController,
            itemCount: profilePhotos.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                profilePhotos[index],
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.yellow,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.yellow),
              );
            },
          ),
        ),
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: profilePhotos.asMap().entries.map((entry) {
              return Container(
                width: MediaQuery.of(context).size.width / profilePhotos.length - 4,
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _currentImageIndex == entry.key ? Colors.yellow : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData.name ?? currentUser?.displayName ?? 'No Name',
                style: GoogleFonts.poppins(
                  fontSize: 32.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                userData.majorInfo ?? "No major info",
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 8),
              Text(
                userData.biography ?? "No biography available.",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSettings()));
            },
            child: Hero(
              tag: "Profile Screen",
              child: Icon(Icons.settings, size: 30.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTrack() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.yellow));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data?.track == null) {
          return SizedBox.shrink();
        }

        final track = snapshot.data!.track!;
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          color: Colors.yellow.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.music_note, color: Colors.yellow),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${track.artist.name} - ${track.name}',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopArtists(SpotifyArtistsResponse artists) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Top Artists',
            style: TextStyle(color: Colors.yellow, fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.items.length,
            itemBuilder: (context, index) {
              final artist = artists.items[index];
              return Container(
                width: 100,
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        artist.images.isNotEmpty ? artist.images[0].url : '',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      artist.name,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopTracks(List<SpotifyTrack> tracks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Top Tracks',
            style: TextStyle(color: Colors.yellow, fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return ListTile(
              leading: Image.network(
                track.album.images.isNotEmpty ? track.album.images[0].url : '',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.yellow),
              ),
              title: Text(track.name, style: TextStyle(color: Colors.white)),
              subtitle: Text(track.artists.map((artist) => artist.name).join(', '), style: TextStyle(color: Colors.white.withOpacity(0.7))),
            );
          },
        ),
      ],
    );
  }
}
