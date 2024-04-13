// import 'dart:ffi' as prefix;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/main.dart';
import 'package:spotify_project/widgets/personal_info_bar.dart';

class SharePostScreen extends StatelessWidget {
  TextEditingController _captionTextController = TextEditingController();
  FirestoreDatabaseService _firestoreDatabaseService =
      FirestoreDatabaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back)),
          title: Text('Share Your Post'),
        ),
        body: Scaffold(
            body: FutureBuilder(
          future: _firestoreDatabaseService.getBeingSharedPostData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenHeight / 15,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth / 5),
                      child: Container(
                        color: Colors.amber,
                        width: screenWidth / 1.6,
                        child: Image(
                            image: NetworkImage(snapshot.data!["sharedPost"])),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight / 15,
                    ),
                    PersonalInfoNameBar(
                      label: "Description",
                      lineCount: 5,
                      controller: _captionTextController,
                      methodToRun: _firestoreDatabaseService.updateCaption,
                    ),
                    SizedBox(
                      height: screenHeight / 77,
                    ),
                    Container(
                      height: screenHeight / 25,
                      width: screenWidth / 2.6,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Color.fromARGB(255, 15, 211, 250),
                            backgroundColor: Color.fromARGB(255, 0, 0, 0),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17)),
                            minimumSize: const Size(double.infinity, 50)),
                        onPressed: () {
                          if (_captionTextController.text.length > 110) {
                            callSnackbar("Your caption is too long!",
                                Colors.red, context);
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                              // TODO: Aşağıya ayar çek.
                              builder: (context) => Home(),
                            ));
                            callSnackbar("Your post has been shared!",
                                Colors.green, context);
                          }
                        },
                        child: Text(
                          "Share!",
                          style:
                              TextStyle(color: Colors.white, fontSize: 20.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        )));
  }
}

void callSnackbar(String error, [Color? color, context]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
    //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    backgroundColor: color ?? Colors.red,
    duration: Duration(seconds: 4),
    // onVisible: onVisible,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    content: SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: Text(error, style: const TextStyle(color: Colors.white)),
      ),
    ),
  ));
}
