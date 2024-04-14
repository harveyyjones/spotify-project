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
import 'package:spotify_project/widgets/personal_info_bar.dart';

final User? currentUser = FirebaseAuth.instance.currentUser;
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
        // appBar: AppBar(title: const Text(_title)),
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
File? _image;
User? user;

class SteppersForClientsWidgetState extends State<SteppersForClientsWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<File?> cropImage(File imageFile) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
    );
    return File(croppedImage!.path);
  }

  Future pickImage(ImageSource source) async {
    try {
      uploadImageToDatabase() async {
        UploadTask? uploadTask;
        final ref = FirebaseStorage.instance
            .ref()
            .child("users")
            .child(currentUser!.uid)
            .child("profil.jpg");

        uploadTask = ref.putFile(_image!);
        var uri = await (uploadTask
            .whenComplete(() => ref.getDownloadURL().then((value) {
                  downloadImageURL = value;
                  if (mounted) {
                    setState(() {});
                  }
                })));
        print("Profil fotosu URL'i : ${downloadImageURL}");
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

  @override
  Widget build(BuildContext context) {
    @override
    FirestoreDatabaseService _firestoreDatabaseService =
        FirestoreDatabaseService();
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
                              const Duration(seconds: 4);
                              if (downloadImageURL != null) {
                                await _firestoreDatabaseService
                                    .updateProfilePhoto(downloadImageURL!);

                                // ignore: use_build_context_synchronously
                                await Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Home(),
                                    ),
                                    (route) => false);
                              } else {
                                callSnackbar(String error,
                                    [Color? color, onVisible]) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 30.w, vertical: 30.h),
                                    //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    backgroundColor: color ??
                                        Color.fromARGB(255, 65, 221, 4),
                                    duration: Duration(milliseconds: 500),
                                    onVisible: onVisible,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    content: SizedBox(
                                      width: 40.w,
                                      height: 40.h,
                                      child: Center(
                                        child: Text(error,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ));
                                }

                                callSnackbar("Your account is created.");
                              }
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ),
                                  (route) => false);
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
                        CircleAvatar(
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          //backgroundColor: Colors.white,
                          maxRadius: screenWidth / 3.3,
                          minRadius: 20,
                        ),
                        SizedBox(
                          height: screenHeight / 33,
                        ),
                        const Text(
                          "Add a picture for your awesome profile!",
                          style: TextStyle(fontSize: 28, color: Colors.black),
                        ),
                        InkWell(
                          onTap: () {
                            pickImage(ImageSource.gallery);

                            print("Image picker basıldı");
                          },
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
            // color: Colors.black,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: Text(
                    "To help you complete your profile you should answer some quick questions.",
                    style: TextStyle(
                        // fontFamily: fontFamilyJavanese,
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
