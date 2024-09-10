import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/main.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/widgets/personal_info_bar.dart';

TextEditingController _controllerForName = TextEditingController();
TextEditingController _controllerForMajorInfo = TextEditingController();
TextEditingController _controllerForClinicLocation = TextEditingController();
TextEditingController _controllerForBiography = TextEditingController();
TextEditingController _controllerForClinicName = TextEditingController();
var profilePhoto;
int _index = 0;

class SteppersForClients extends StatelessWidget {
  const SteppersForClients({super.key});

  static const String _title = '';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: Scaffold(
        body: Center(
          child: SteppersForClientsWidget(),
        ),
      ),
    );
  }
}

class SteppersForClientsWidget extends StatefulWidget {
  const SteppersForClientsWidget({super.key});

  @override
  State<SteppersForClientsWidget> createState() =>
      SteppersForClientsWidgetState();
}

FirestoreDatabaseService _firestore_database_service =
    FirestoreDatabaseService();
String? downloadImageURL;
List<File> _images = [];
User? user;

class SteppersForClientsWidgetState extends State<SteppersForClientsWidget> {

  Future<File?> cropImage(File imageFile) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
    );
    return croppedImage != null ? File(croppedImage.path) : null;
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      
      File? img = File(image.path);
      img = await cropImage(img);
      if (img != null) {
        setState(() {
          _images.add(img!);
          profilePhoto = img;
        });
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future uploadImagesToDatabase() async {
    if (_images.isEmpty) return;

    for (var i = 0; i < _images.length; i++) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("users")
          .child(currentUser!.uid)
          .child("profile_$i.jpg");

      UploadTask uploadTask = ref.putFile(_images[i]);
      await uploadTask.whenComplete(() async {
        String url = await ref.getDownloadURL();
        if (i == 0) {
          downloadImageURL = url;
          await _firestore_database_service.updateProfilePhoto(downloadImageURL!);
        }
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_images.isNotEmpty) {
        profilePhoto = _images[0];
      } else {
        profilePhoto = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _keyForStepper = GlobalKey();
    return SafeArea(
        child: Scaffold(
      body: Material(
        color: const Color.fromARGB(255, 236, 243, 250),
        child: Stepper(
            key: _keyForStepper,
            controlsBuilder: (context, details) {
              return details.stepIndex == 1
                  ? Column(
                      children: [
                        SizedBox(
                          height: screenHeight / 20,
                        ),
                        TextButton(
                            onPressed: () async {
                              await uploadImagesToDatabase();
                              // Navigate to the home page
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => Home()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Text(
                              "Finish",
                              style: TextStyle(fontSize: 40.sp),
                            )),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            if (_index != 5) {
                              setState(() {
                                _index += 1;
                              });
                            }
                          },
                          child: const Text(
                            'Next',
                            style: TextStyle(fontSize: 26),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_index > 0) {
                              setState(() {
                                _index -= 1;
                              });
                            }
                          },
                          child: const Text(
                            "Back",
                            style: TextStyle(fontSize: 26),
                          ),
                        ),
                      ],
                    );
            },
            type: StepperType.horizontal,
            currentStep: _index,
            onStepCancel: () {
              if (_index > 0) {
                setState(() {
                  _index -= 1;
                });
              }
            },
            onStepContinue: () {
              if (_index != 2) {
                setState(() {
                  _index += 1;
                });
              }
            },
            onStepTapped: (int index) {
              setState(() {
                _index = index;
              });
            },
            steps: [
              ...stepList,
              Step(
                isActive: _index > 1,
                state: _index > 4 ? StepState.complete : StepState.indexed,
                title: const Text(''),
                content: Container(
                  padding: EdgeInsets.only(top: screenHeight / 25),
                  alignment: Alignment.centerLeft,
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => pickImage(ImageSource.gallery),
                          child: Container(
                            width: screenWidth / 1.5,
                            height: screenWidth / 1.5,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _images.isEmpty
                                ? Icon(Icons.add_photo_alternate, size: 50)
                                : GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                    ),
                                    itemCount: _images.length,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          Image.file(_images[index], fit: BoxFit.cover),
                                          Positioned(
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () => removeImage(index),
                                              child: Container(
                                                color: Colors.red,
                                                child: Icon(Icons.close, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                        SizedBox(height: screenHeight / 33),
                        Text(
                          "Add pictures for your awesome profile!",
                          style: TextStyle(fontSize: 28, color: Colors.black),
                        ),
                        SizedBox(height: screenHeight / 33),
                        InkWell(
                          onTap: () => pickImage(ImageSource.gallery),
                          child: Container(
                            decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(1, 2),
                                    blurRadius: 1,
                                    blurStyle: BlurStyle.outer,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(22),
                                color: Colors.white),
                            width: screenWidth / 2.5,
                            height: screenHeight / 12,
                            child: const Center(
                              child: Text(
                                "Add Photo",
                                style: TextStyle(
                                    fontSize: 33, fontFamily: "Javanese"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
      ),
    ));
  }
}

List<Step> get stepList => <Step>[
      Step(
        isActive: true,
        state: _index > 0 ? StepState.complete : StepState.indexed,
        title: const Text(''),
        content: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: Text(
                    "To help you complete your profile you should answer some quick questions.",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(
                  height: screenHeight / 33,
                ),
                PersonalInfoNameBar(
                  controller: _controllerForName,
                  methodToRun: _firestore_database_service.updateName,
                  label: "What's your name?",
                  lineCount: 1,
                ),
                const Text(
                  "This will be seen by everyone.",
                  style: TextStyle(fontSize: 22),
                ),
              ],
            )),
      ),
    ];

void callSnackbar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
    backgroundColor: Color.fromARGB(255, 65, 221, 4),
    duration: Duration(milliseconds: 500),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    content: SizedBox(
      width: 40.w,
      height: 40.h,
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    ),
  ));
}