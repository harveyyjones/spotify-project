import 'package:flutter/material.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Business_Logic/Models/user_model.dart';
import 'package:spotify_project/widgets/bottom_bar.dart'; // Add this import

class LikesScreen extends StatefulWidget {
  @override
  _LikesScreenState createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  final FirestoreDatabaseService _databaseService = FirestoreDatabaseService();
  late Future<List<UserModel>> _peopleWhoLikedMeFuture;

  @override
  void initState() {
    super.initState();
    _peopleWhoLikedMeFuture = _databaseService.getPeopleWhoLikedMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('People Who Liked You'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _peopleWhoLikedMeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No one has liked you yet.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                UserModel user = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      user.profilePhotos.isNotEmpty
                          ? user.profilePhotos.first
                          : 'https://example.com/default_profile_image.jpg'
                    ),
                  ),
                  title: Text(user.name ?? 'No Name'),
                  subtitle: Text(user.majorInfo ?? 'No Major Info'),
                  onTap: () {
                    // Navigate to user profile or show more details
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomBar(selectedIndex: 4,), // Add this line
    );
  }
}
