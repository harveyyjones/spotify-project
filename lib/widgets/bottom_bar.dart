import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/main.dart';
import 'package:spotify_project/screens/matches_screen.dart';
import 'package:spotify_project/screens/message_box.dart';
import 'package:spotify_project/screens/own_profile_screens_for_clients.dart';

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
    const Home(),
    // OwnProfileScreen(),
    MessageScreen()
  ];

  final List _pagesToNavigateToForClients = [
    const Home(),
    const MatchesScreen(),
    OwnProfileScreenForClients(),
    MessageScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff2f9ff),
      height: screenHeight / 14,
      child: FutureBuilder(
        future: _firestoreDatabaseService.getUserData(),
        builder: (context, snapshot) => BottomNavigationBar(
            backgroundColor: const Color(0xfff2f9ff),
            selectedItemColor: Colors.blue,
            selectedFontSize: 0,
            currentIndex: widget.selectedIndex,
            onTap: (value) {
              _index = value;
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) {
                if (snapshot.data!.clinicOwner == false) {
                  return _pagesToNavigateToForClients[value];
                } else {
                  return _pagesToNavigateToForClinicOwners[value];
                }
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
            ]),
      ),
    );
  }
}
