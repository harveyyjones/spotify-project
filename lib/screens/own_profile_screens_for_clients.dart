import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/screens/profile_settings.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/widgets/bottom_bar.dart';

class OwnProfileScreenForClients extends StatefulWidget {
  OwnProfileScreenForClients({Key? key}) : super(key: key);

  @override
  State<OwnProfileScreenForClients> createState() =>
      _OwnProfileScreenForClientsState();
}

class _OwnProfileScreenForClientsState
    extends State<OwnProfileScreenForClients> {
  ScrollController _scrollController = ScrollController();

  String get text => "Message";
  FirestoreDatabaseService _serviceForSnapshot = FirestoreDatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _serviceForSnapshot.getUserData(),
        builder: (context, snapshot) => snapshot.hasData
            ? Scaffold(
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

                                // color: Color(0xffecfeff),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: screenHeight / 14,
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          //  color: Colors.amber,
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
                                    // ******************** isim ***********************
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
                                    // ********** BİYOGRAFİ *********
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
                                            fontSize: 36.sp,
                                            color: Color(0xff707070)),
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
                                            //*********** Klinik İsmi *********************
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
                                            //   ****************** Unvan ************
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
                                            //   color: Colors.black,
                                            child: Text(
                                              snapshot.data!.clinicLocation ??
                                                  "Turkey",
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
                      // ******************** Postlar burada başlıyor. **********************
                      StreamBuilder(
                          stream: _serviceForSnapshot.getAllSharedPosts(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              QuerySnapshot querySnapshot =
                                  snapshot.data as QuerySnapshot;
                              return Container(
                                // color: Colors.amber,
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
                                          // color: Colors.red,
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
                                          // color: Colors.red,
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
                          })
                    ],
                  ),
                ),
              )
            : CircularProgressIndicator());
  }
}
