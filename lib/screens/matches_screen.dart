import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/main.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/widgets/bottom_bar.dart';
import 'package:spotify_project/widgets/swipe_card.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final FirestoreDatabaseService _firestoreDatabaseService = FirestoreDatabaseService();
  String? _errorMessage;
  bool _isLoading = true;
  List<dynamic>? _matchData;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      String currentlyListeningMusicName = await _getCurrentlyListeningMusic();
      bool isSpotifyActive = await _checkSpotifyStatus();

      await _firestoreDatabaseService.getUserDatasToMatch(
        currentlyListeningMusicName,
        isSpotifyActive,
      );

      _matchData = await _firestoreDatabaseService.getUserDataViaUId();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error initializing user data: $e";
        _isLoading = false;
      });
    }
  }

  Future<String> _getCurrentlyListeningMusic() async {
    try {
      String? musicName = await _firestoreDatabaseService.returnCurrentlyListeningMusicName();
      return musicName ?? '';
    } catch (e) {
      print("Error getting currently listening music: $e");
      return '';
    }
  }

  Future<bool> _checkSpotifyStatus() async {
    try {
      return await SpotifySdk.isSpotifyAppActive;
    } catch (e) {
      print("Error checking Spotify active status: $e");
      return false;
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Text(
        _errorMessage ?? "An unknown error occurred",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.red),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.black),
    );
  }

  Widget _buildNoDataWidget(String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMatchesWidget() {
    if (_matchData == null || _matchData!.isEmpty) {
      return _buildNoDataWidget("No matches found. Try listening to some music!");
    }

    if (_matchData!.length == 1 && _matchData![0].userId == currentUser?.uid) {
      return _buildNoDataWidget("There is no match yet, listen to some music or use quick match!");
    }

    return Container(
      color: Color.fromARGB(255, 234, 243, 252),
      child: Column(
        children: [
          const SizedBox(width: double.infinity),
          Container(
            width: screenWidth - 30,
            height: screenHeight * (12 / 13),
            child: SwipeCardWidget(snapshotData: _matchData),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(selectedIndex: 1),
      body: _isLoading
          ? _buildLoadingWidget()
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildMatchesWidget(),
    );
  }
}