import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/business/Spotify_Logic/Models/top_10_track_model.dart';
// import 'package:spotify_project/business/Spotify_Logic/Models/top_artists_of_the_user.dart';
import 'package:spotify_project/business/Spotify_Logic/constants.dart';
import 'package:spotify_project/business/Spotify_Logic/services/fetch_artists.dart';
import 'package:spotify_project/business/Spotify_Logic/services/fetch_top_10_tracks_of_the_user.dart';
import 'package:spotify_project/screens/profile_settings.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/widgets/bottom_bar.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class OwnProfileScreenForClients extends StatefulWidget {
  OwnProfileScreenForClients({Key? key}) : super(key: key);

  @override
  State<OwnProfileScreenForClients> createState() =>
      _OwnProfileScreenForClientsState();
}

class _OwnProfileScreenForClientsState
    extends State<OwnProfileScreenForClients> {
  final ScrollController _scrollController = ScrollController();
  final FirestoreDatabaseService _serviceForSnapshot =
      FirestoreDatabaseService();
  late Future<SpotifyArtistsResponse> _futureArtists;
  late Future<List<SpotifyTrack>> _futureTracks;

  @override
  void initState() {
    super.initState();
    _futureArtists = SpotifyServiceForTopArtists(accessToken).fetchArtists();
    _futureTracks = SpotifyService(accessToken).fetchTracks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _serviceForSnapshot.getUserData(),
        builder: (context, snapshot) => snapshot.hasData
            ? Scaffold(
                floatingActionButton: FloatingActionButton(
                  elevation: 0,
                  child: Icon(Icons.plus_one),
                  onPressed: () async {
                    await _serviceForSnapshot.sharePost(
                        ImageSource.gallery, context);
                  },
                ),
                backgroundColor: Color(0xfff2f9ff),
                bottomNavigationBar: snapshot.data!.clinicOwner ?? true
                    ? BottomBar(
                        selectedIndex: 2,
                      )
                    : BottomBar(selectedIndex: 2),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      FutureBuilder(
                          future: _serviceForSnapshot.getUserData(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                width: screenWidth,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: screenHeight / 14,
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          height: screenHeight / 2.6,
                                        ),
                                        Positioned(
                                          top: screenHeight / 8.5,
                                          left: screenWidth / 3.4,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            child: Image(
                                              width: screenWidth / 2.5,
                                              fit: BoxFit.fill,
                                              image: NetworkImage(snapshot.data!
                                                              .profilePhotoURL !=
                                                          null &&
                                                      snapshot
                                                          .data!
                                                          .profilePhotoURL!
                                                          .isNotEmpty
                                                  ? snapshot
                                                      .data!.profilePhotoURL!
                                                  : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            top: screenHeight / 3.4,
                                            right: screenWidth / 3.8,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfileSettings(),
                                                    ));
                                              },
                                              child: Hero(
                                                  tag: "Profile Screen",
                                                  child: Icon(
                                                    Icons.settings,
                                                    size: 80.sp,
                                                  )),
                                            )),
                                      ],
                                    ),
                                    SizedBox(
                                      height: screenHeight / 3330,
                                    ),
                                    Text(
                                        snapshot.data!.name ??
                                            currentUser!.displayName!,
                                        style: GoogleFonts.poppins(
                                            fontSize: 52.sp,
                                            color:
                                                Color.fromARGB(255, 58, 57, 57),
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(
                                      height: screenHeight / 55,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 55),
                                      child: Text(
                                        snapshot.data!.biography ??
                                            "That'd be just okay if you listen Rock.",
                                        softWrap: true,
                                        style: TextStyle(
                                            fontFamily: "Javanese",
                                            height: 1.3,
                                            fontSize: 40.sp,
                                            color: Color.fromARGB(
                                                255, 72, 71, 71)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenHeight / 122,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: screenWidth / 10,
                                          height: screenHeight / 44,
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                right: screenWidth / 77,
                                                top: screenHeight / 30),
                                            child: Text(
                                              snapshot.data!.clinicName ??
                                                  "mango hosp",
                                              softWrap: true,
                                              style: TextStyle(
                                                  fontFamily: "Javanese",
                                                  height: 1.3,
                                                  fontSize: 36.sp,
                                                  color: Color(0xff707070)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth / 17,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: screenWidth / 10,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: screenWidth / 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                right: screenWidth / 77),
                                            child: Text(
                                              snapshot.data!.majorInfo ?? "",
                                              softWrap: true,
                                              style: TextStyle(
                                                  fontFamily: "Javanese",
                                                  height: 1.3,
                                                  fontSize: 28.sp,
                                                  color: Color(0xff707070)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: screenWidth / 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                right: screenWidth / 77),
                                            child: Text(
                                              snapshot.data!.clinicLocation ??
                                                  "Turkey",
                                              softWrap: true,
                                              style: TextStyle(
                                                  fontFamily: "Javanese",
                                                  height: 1.3,
                                                  fontSize: 35.sp,
                                                  color: Color.fromARGB(
                                                      255, 78, 78, 78)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: screenHeight / 22,
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          }),
                      // ******************** Posts Section **********************
                      StreamBuilder(
                          stream: _serviceForSnapshot.getAllSharedPosts(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              QuerySnapshot querySnapshot =
                                  snapshot.data as QuerySnapshot;
                              return Container(
                                width: screenWidth / 1.4,
                                height: querySnapshot.docs.length * 760,
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: querySnapshot.docs.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot documentSnapshot =
                                        querySnapshot.docs[index];
                                    return Column(
                                      children: [
                                        Container(
                                          width: screenWidth / 1,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(16),
                                                    topLeft:
                                                        Radius.circular(16)),
                                            child: Image(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  documentSnapshot[
                                                      "sharedPost"]),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: screenHeight / 8,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 221, 219, 219),
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(16),
                                                  bottomRight:
                                                      Radius.circular(16))),
                                          child: Padding(
                                            padding: EdgeInsets.all(30),
                                            child: Center(
                                              child: Text(
                                                documentSnapshot["caption"],
                                                style:
                                                    TextStyle(fontSize: 25.sp),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: screenHeight / 16,
                                        )
                                      ],
                                    );
                                  },
                                ),
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          }),
                      FutureBuilder<SpotifyArtistsResponse>(
                        future: _futureArtists,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.items.length,
                              itemBuilder: (context, index) {
                                final artist = snapshot.data!.items[index];
                                return ListTile(
                                  leading: Image.network(
                                    artist.images.isNotEmpty
                                        ? artist.images[0].url
                                        : '',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(artist.name),
                                  subtitle:
                                      Text('Popularity: ${artist.popularity}'),
                                  onTap: () {
                                    // Handle artist item tap if needed
                                  },
                                );
                              },
                            );
                          } else {
                            return Center(child: Text('No data available'));
                          }
                        },
                      ),
                      Divider(
                        thickness: 2,
                        color: Colors.black,
                      ),
                      // ******************** Top Tracks Section **********************
                      FutureBuilder<List<SpotifyTrack>>(
                        future: _futureTracks,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final track = snapshot.data![index];
                                return ListTile(
                                  leading: Image.network(
                                    track.album.images.isNotEmpty
                                        ? track.album.images[0].url
                                        : '',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(track.name),
                                  subtitle: Text(track.artists
                                      .map((artist) => artist.name)
                                      .join(', ')),
                                  onTap: () {
                                    // TODO: Apply URL Launcher to play the song.
                                  },
                                );
                              },
                            );
                          } else {
                            return Center(child: Text('No data available'));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            : CircularProgressIndicator());
  }
}
