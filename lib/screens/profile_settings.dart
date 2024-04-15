import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/screens/own_profile_screens_for_clients.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/screens/steppers.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

late FirestoreDatabaseService _databaseService = FirestoreDatabaseService();
late FirebaseFirestore _instance = FirebaseFirestore.instance;

class _ProfileSettingsState extends State<ProfileSettings> {
  File? _image;
  @override
  Widget build(BuildContext context) {
    Future<File?> cropImage(File imageFile) async {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
          aspectRatioPresets: [CropAspectRatioPreset.square],
          sourcePath: imageFile.path);
      print("Image File Path: ${imageFile.path}");
      return File(croppedImage!.path);
    }

    Future pickImage(ImageSource source) async {
      try {
        uploadImageToDatabase() async {
          UploadTask? uploadTask;
          Reference ref = FirebaseStorage.instance
              .ref()
              .child("users")
              .child(currentUser!.uid)
              .child("profil.jpg");

          uploadTask = ref.putFile(_image!);
          var uri = await (uploadTask
              .whenComplete(() => ref.getDownloadURL().then((value) {
                    downloadImageURL = value;
                    setState(() {});
                    _databaseService.updateProfilePhoto(downloadImageURL!);
                  })));
          print("Profil fotosu URL'i ayarlardan : ${downloadImageURL}");
        }

        final image = await ImagePicker().pickImage(source: source);
        if (image == null) {
          return;
        } else {
          File? img = File(image.path);
          img = (await cropImage(img));
          setState(() {
            _image = img;
          });

          uploadImageToDatabase();
        }
      } on PlatformException catch (e) {
        print(e.message);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OwnProfileScreenForClients(),
                )),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 50.sp,
            )),
        backgroundColor: Color(0xffecfeff),
      ),
      body: StreamBuilder(
        stream: _databaseService.getProfileData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            TextEditingController nameController =
                TextEditingController(text: snapshot.data!["name"]);
            nameController.selection = TextSelection.fromPosition(
                TextPosition(offset: nameController.text.length));

            TextEditingController biographyController =
                TextEditingController(text: snapshot.data!["biography"]);
            biographyController.selection = TextSelection.fromPosition(
                TextPosition(offset: biographyController.text.length));

            TextEditingController majorInfoController =
                TextEditingController(text: snapshot.data!["majorInfo"]);
            majorInfoController.selection = TextSelection.fromPosition(
                TextPosition(offset: majorInfoController.text.length));

            TextEditingController clinicLocationController =
                TextEditingController(text: snapshot.data!["clinicLocation"]);
            clinicLocationController.selection = TextSelection.fromPosition(
                TextPosition(offset: clinicLocationController.text.length));

            TextEditingController clinicNameController =
                TextEditingController(text: snapshot.data!["clinicName"]);
            clinicNameController.selection = TextSelection.fromPosition(
                TextPosition(offset: clinicNameController.text.length));

            return SingleChildScrollView(
              child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  // padding: EdgeInsets.only(top: screenHeight / 20),
                  decoration: const BoxDecoration(
                    color: Color(0xffecfeff),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Stack(
                            children: [
                              Container(
                                //  color: Colors.amber,
                                height: screenHeight / 2.6,
                              ),
                              // Container(
                              //   color: Colors.amber,
                              //   child: ClipRRect(
                              //     borderRadius: BorderRadius.circular(5),
                              //     child: Image(
                              //         width: screenWidth,
                              //         height: screenHeight / 4,
                              //         fit: BoxFit.cover,
                              //         image: const NetworkImage(
                              //             "https://i.pinimg.com/564x/67/ed/fe/67edfe57c3c518ca158c35d4b9a77215.jpg")),
                              //   ),
                              // ),
                              Positioned(
                                top: screenHeight / 7,
                                left: screenWidth / 3.4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image(
                                      width: screenWidth / 2.5,
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                          snapshot.data!["profilePhotoURL"] ??
                                              "")),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                              right: screenWidth / 4,
                              top: screenHeight / 3.3,
                              child: IconButton(
                                  iconSize: 75.sp,
                                  onPressed: () {
                                    pickImage(ImageSource.gallery);
                                  },
                                  icon: const Icon(
                                      color: Color.fromARGB(255, 160, 201, 245),
                                      Icons.image_search)))
                        ],
                      ),
                      SizedBox(
                        height: screenHeight / 55,
                        width: MediaQuery.of(context).size.width,
                      ),
                      // **************************** Name *******************************
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 160.w,
                            height: screenHeight / 11,
                            //  color: Color.fromARGB(255, 194, 6, 6),
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 40.w, right: 15.w),
                                child: TextFormField(
                                    validator: (value) {
                                      if (value!.length < 1) {
                                        _databaseService.updateBiography(value);
                                      } else {
                                        return "Too long!";
                                      }
                                    },
                                    onChanged: (value) {
                                      if (value.length < 15) {
                                        _databaseService.updateName(value);
                                      }
                                    },
                                    controller: nameController,
                                    //  initialValue: snapshot.data!["name"],
                                    obscureText: false,
                                    style: TextStyle(
                                        height: 0.9,
                                        fontSize: 33.sp,
                                        fontFamily: "Calisto",
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      label: Text(
                                        "Name",
                                        style: TextStyle(
                                            fontSize: 27.sp,
                                            fontFamily: "Calisto",
                                            color: Color.fromARGB(
                                                129, 42, 41, 41)),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight / 66,
                          )
                        ],
                      ),
                      // ****************** Status ************************
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 160.w,
                            height: screenHeight / 8,
                            color: Colors.transparent,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 40.w, right: 15.w),
                                child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.length < 200) {
                                        _databaseService.updateBiography(value);
                                      } else {
                                        return "Too long!";
                                      }
                                    },
                                    onChanged: (value) {
                                      if (value.length < 200) {
                                        _databaseService.updateBiography(value);
                                      }
                                    },
                                    controller: biographyController,
                                    obscureText: false,
                                    style: TextStyle(
                                        height: 0.9,
                                        fontSize: 33.sp,
                                        fontFamily: "Calisto",
                                        fontWeight: FontWeight.w500),
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      label: Text(
                                        "Status",
                                        style: TextStyle(
                                            fontSize: 27.sp,
                                            fontFamily: "Calisto",
                                            color: const Color.fromARGB(
                                                129, 42, 41, 41)),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight / 66,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 160.w,
                            height: screenHeight / 7.5,
                            color: Colors.transparent,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 40.w, right: 15.w),
                                child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.length < 100) {
                                        _databaseService
                                            .updateClinicName(value);
                                      } else {
                                        return "Too long!";
                                      }
                                    },
                                    onChanged: (value) {
                                      if (value.length < 200) {
                                        _databaseService
                                            .updateClinicName(value);
                                      }
                                    },
                                    controller: clinicNameController,
                                    obscureText: false,
                                    style: TextStyle(
                                        height: 0.9,
                                        fontSize: 33.sp,
                                        fontFamily: "Calisto",
                                        fontWeight: FontWeight.w500),
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      label: Text(
                                        "Clinic Name",
                                        style: TextStyle(
                                            fontSize: 27.sp,
                                            fontFamily: "Calisto",
                                            color: const Color.fromARGB(
                                                129, 42, 41, 41)),
                                      ),
                                    )),
                              ),
                            ),
                          ),

                          // ********************** Major Info **********************************
                          Container(
                            width: MediaQuery.of(context).size.width - 160.w,
                            height: screenHeight / 10,
                            color: Colors.transparent,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 40.w, right: 15.w),
                                child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.length < 200) {
                                        // TODO: Update major info metodu yaz.
                                        _databaseService.updateMajorInfo(value);
                                      } else {
                                        return "Too long!";
                                      }
                                    },
                                    onChanged: (value) {
                                      if (value.length < 200) {
                                        _databaseService.updateMajorInfo(value);
                                      }
                                    },
                                    controller: majorInfoController,
                                    obscureText: false,
                                    style: TextStyle(
                                        height: 0.9,
                                        fontSize: 33.sp,
                                        fontFamily: "Calisto",
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      label: Text(
                                        "Major",
                                        style: TextStyle(
                                            fontSize: 27.sp,
                                            fontFamily: "Calisto",
                                            color: const Color.fromARGB(
                                                129, 42, 41, 41)),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight / 66,
                          ),
                          // ************************ Clinic Location ****************************
                          Container(
                            width: MediaQuery.of(context).size.width - 160.w,
                            height: screenHeight / 10,
                            color: Colors.transparent,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 40.w, right: 15.w),
                                child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.length < 200) {
                                        // TODO: Update major info metodu yaz.
                                        _databaseService
                                            .updateClinicLocation(value);
                                      } else {
                                        return "Too long!";
                                      }
                                    },
                                    onChanged: (value) {
                                      if (value.length < 200) {
                                        _databaseService
                                            .updateClinicLocation(value);
                                      }
                                    },
                                    controller: clinicLocationController,
                                    obscureText: false,
                                    style: TextStyle(
                                        height: 0.9,
                                        fontSize: 33.sp,
                                        fontFamily: "Calisto",
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      label: Text(
                                        "Clinic Location",
                                        style: TextStyle(
                                            fontSize: 27.sp,
                                            fontFamily: "Calisto",
                                            color: const Color.fromARGB(
                                                129, 42, 41, 41)),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Expanded(
                        child: SizedBox(),
                      ),
                    ],
                  )),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

callSnackbar(
  String error,
  context, [
  Color? color,
  VoidCallback? onVisible,
]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
    //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    backgroundColor: color ?? Colors.red,
    duration: Duration(milliseconds: 5),
    onVisible: onVisible,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    content: SizedBox(
      width: 40.w,
      height: 40.h,
      child: Center(
        child: Text(error, style: const TextStyle(color: Colors.white)),
      ),
    ),
  ));
}
