import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_project/Business_Logic/firestore_database_service.dart';
import 'package:spotify_project/screens/steppers.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

FirebaseAuth auth = FirebaseAuth.instance;

final User? currentUser = FirebaseAuth.instance.currentUser;

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  bool isVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfff2f9ff),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        child: _buildForm(context, screenWidth, screenHeight),
      ),
    );
  }

  // formun oluşturulması
  Form _buildForm(
      BuildContext context, double screenWidth, double screenHeight) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: screenHeight / 5,
          ),
          Text(
            "Sign Up",
            style: GoogleFonts.poppins(
              fontSize: 30.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
          SizedBox(
            height: screenHeight / 45,
          ),
          _buildname(screenWidth),
          SizedBox(height: screenHeight / 35),
          _buildEmailField(screenWidth),
          SizedBox(height: screenHeight / 35),
          _buildphoneNumber(screenWidth),
          SizedBox(height: screenHeight / 35),
          _buildPasswordField(screenWidth),
          SizedBox(height: screenHeight / 35),
          _buildRegisterInButton(context, screenWidth),
        ],
      ),
    );
  }

  // isim alanı
  Widget _buildname(double screenWidth) {
    return Container(
      width: screenWidth / 1.7,
      height: screenWidth / 9,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white.withOpacity(0.6),
          ),
          child: TextFormField(
            controller: nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value!.isEmpty) {
                callSnackbar('İsim boş olamaz!');
                return '';
              } else if (value.length < 2) {
                callSnackbar('İsminiz minumum iki karakterden oluşmalıdır!');
                return '';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Name",
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
    ).hasMatch(email);
  }

  // e-mail alanı
  Widget _buildEmailField(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth / 7),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value!.isEmpty) {
            callSnackbar('Email boş olamaz!');
            return '';
          } else if (!isValidEmail(value)) {
            callSnackbar('Email formatı hatalı!');
            return '';
          }
          return null;
        },
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          label: Text(
            "E Mail",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          border: const OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 0, 255, 0), width: 2),
          ),
        ),
      ),
    );
  }

  // şifre alanı
  Widget _buildPasswordField(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth / 7),
      child: TextFormField(
        controller: passwordController,
        validator: (value) {
          if (value!.isNotEmpty) {
            if (value.length < 6) {
              callSnackbar("Şifreniz minimum 6 haneli olmalıdır.");
              return '';
            }
          } else {
            callSnackbar("Şifre alanı boş olamaz!");
            return '';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          label: Text(
            "Password",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          border: const OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 0, 255, 0), width: 2),
          ),
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                isVisible = !isVisible;
              });
            },
            child: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
        obscureText: !isVisible,
      ),
    );
  }

  // telefon numarası kontrolü
  bool isValidphoneNumber(String phoneNumber) {
    return RegExp(r"(^(?:[+0]9)?[0-9]{10,12}$)").hasMatch(phoneNumber);
  }

  // numara alanı
  Widget _buildphoneNumber(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth / 7),
      child: TextFormField(
        controller: phoneNumberController,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value!.isEmpty) {
            callSnackbar('Telefon numarası boş olamaz!');
            return '';
          } else if (!isValidphoneNumber(value)) {
            callSnackbar('Telefon numarası formatı hatalı!');
            return '';
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          label: Text(
            "Phone Number",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          border: const OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 0, 255, 0), width: 2),
          ),
        ),
      ),
    );
  }

  // kayıt ol butonu
  Widget _buildRegisterInButton(BuildContext context, double screenWidth) {
    FirestoreDatabaseService _firestoreDatabaseService =
        FirestoreDatabaseService();
    return Container(
      width: screenWidth / 2,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.black,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            signUp();
          } else {
            callSnackbar("Something went wrong, please check your informs.");
          }
        },
        child: Text(
          "Sign Up",
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // uyarı mesajı
  void callSnackbar(String error, [Color? color, VoidCallback? onVisible]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      backgroundColor: color ?? Colors.red,
      duration: const Duration(milliseconds: 500),
      onVisible: onVisible,
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

  Future signUp() async {
    FirestoreDatabaseService _firestoreDatabaseService =
        FirestoreDatabaseService();
    User? user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Kullanıcı başarıyla kaydedildikten sonra Firestore'a kullanıcı bilgilerini kaydet
      await _firestoreDatabaseService.saveUser(
        biography: "",
        clinicLocation: "",
        clinicName: "",
        clinicOwner: false,
        majorInfo: "",
        name: "",
        phoneNumber: phoneNumberController.text.toString(),
        photoUrl: "",
        uid: auth.currentUser?.uid,
      );

      user = userCredential.user;
      await user!.updateDisplayName(nameController.text);
      await user.reload();
      user = auth.currentUser;
      Future.delayed(const Duration(seconds: 1));
      callSnackbar("Kayıt başarılı !", Colors.green, () {});
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const SteppersForClients(),
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-exists' ||
          e.code == 'email-already-in-use') {
        callSnackbar("Bu e-mail daha önce kullanılmış!");
        return;
      } else if (e.code == 'phone-number-already-exists') {
        callSnackbar("Bu telefon numarası daha önce alınmış!");
        return;
      }
    }
  }
}
