import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/main.dart';
import 'package:spotify_project/screens/matches_screen.dart';
import 'package:spotify_project/screens/message_box.dart';
import 'package:spotify_project/screens/own_profile_screens_for_clients.dart';
import 'package:spotify_project/screens/likes_screen.dart'; // Add this import

class BottomBar extends StatefulWidget {
  int selectedIndex;

  BottomBar({super.key, required this.selectedIndex});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  FirestoreDatabaseService _firestoreDatabaseService =
      FirestoreDatabaseService();
  var _index = 0;
// İlerde admin paneli gibi kullanırım.
  final List _pagesToNavigateToForClinicOwners = [
     Home(),
    // OwnProfileScreen(),
    MessageScreen()
  ];

  final List _pagesToNavigateToForClients = [
     Home(),
    const MatchesScreen(),
    OwnProfileScreenForClients(),
    MessageScreen(),
    LikesScreen(), // Add this new screen
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 9, 129, 249),
      height: screenHeight / 14,
      child: FutureBuilder(
        future: _firestoreDatabaseService.getUserData(),
        builder: (context, snapshot) => BottomNavigationBar(
            backgroundColor: Color.fromARGB(255, 4, 74, 145),
            selectedItemColor: Colors.blue,
            selectedFontSize: 0,
            currentIndex: widget.selectedIndex,
            onTap: (value) {
              _index = value;
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) {
                return _pagesToNavigateToForClients[value];
              }), (route) => false);
              setState(() {});
            },
            items: [
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    Icons.home,
                    size: 60.sp,
                  ),
                  label: "Home",
                  icon: Icon(
                    size: 50.sp,
                    Icons.home,
                    color: Colors.black,
                  )),
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    Icons.notifications_none_outlined,
                    size: 60.sp,
                  ),
                  label: "Notifications",
                  icon: Icon(
                    size: 50.sp,
                    Icons.notifications_none_outlined,
                    color: Colors.black,
                  )),
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    Icons.person,
                    size: 60.sp,
                  ),
                  label: "Profile",
                  icon: Icon(
                    size: 50.sp,
                    Icons.person,
                    color: Colors.black,
                  )),
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    Icons.message,
                    size: 60.sp,
                  ),
                  label: "Profile",
                  icon: Icon(
                    size: 50.sp,
                    Icons.message,
                    color: Colors.black,
                  )),
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    Icons.favorite,
                    size: 60.sp,
                  ),
                  label: "Likes",
                  icon: Icon(
                    size: 50.sp,
                    Icons.favorite_border,
                    color: Colors.black,
                  )),
            ]),
      ),
    );
  }
}
