import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_project/Helpers/helpers.dart';
import 'package:spotify_project/main.dart';
import 'package:spotify_project/screens/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisible = false;
  late FirebaseAuth auth;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      backgroundColor: const Color(0xfff2f9ff),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              // MyApp(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 55),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildForm(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Form _buildForm(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text("Login",
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                )),
            SizedBox(
              height: screenHeight / 20,
            ),
            _buildEmailField(),
            const SizedBox(
              height: 16,
            ),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildSignInButton(context),
            SizedBox(
              height: screenHeight / 30,
            ),
            _buildDivider(),
            SizedBox(
              height: screenHeight / 30,
            ),
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // iconlarin basladigi yer

                  // SignInSocial.buildSocial(
                  //     context,
                  //     const FaIcon(
                  //       FontAwesomeIcons.apple,
                  //       color: Colors.black,
                  //     )),
                  // SizedBox(width: 16.w),
                  // SignInSocial.buildSocial(
                  //     context,
                  //     const FaIcon(
                  //       FontAwesomeIcons.google,
                  //       color: Colors.black,
                  //     )),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight / 99,
            ),
            // _buildForgotPassword(context),
            SizedBox(height: screenHeight / 99),
            buildNoAccount(context)
          ],
        ),
      ),
    );
  }

  Divider _buildDivider() {
    return const Divider(
      height: 2,
      thickness: 0.5,
      indent: 10,
      endIndent: 0,
      color: Colors.black,
    );
  }

  bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value!.isEmpty) {
          callSnackbar('Email boş olamaz.');
          return '';
        } else if (!isValidEmail(value)) {
          callSnackbar('Email formatı hatalı');
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5)),
        label: Text(
          "E Mail",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.black),
        ),
        border: InputBorder.none,
      ),
    );
  }

  callSnackbar(String error, [Color? color, VoidCallback? onVisible]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(5)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(5)),
          label: Text(
            "Password",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.black),
          ),
          border: InputBorder.none,
          suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },
              child:
                  Icon(isVisible ? Icons.visibility : Icons.visibility_off))),
      obscureText: !isVisible,
    );
  }

  // GestureDetector _buildForgotPassword(BuildContext context) {
  //   return GestureDetector(
  //       child: const Text(
  //         "Forgot Password?",
  //         style: TextStyle(
  //             fontSize: 23,
  //             decoration: TextDecoration.underline,
  //             color: Colors.black54),
  //       ),
  //       // şifre unuttum kismi burda birazdan yap
  //       onTap: () {
  //         Navigator.push(context,
  //             MaterialPageRoute(builder: (context) => const ForgotPassword()));
  //       });
  // }

  RichText buildNoAccount(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: const TextStyle(color: Colors.black54, fontSize: 24),
            text: "No Account? ",
            children: [
          TextSpan(
              // hesabın olmaması burda
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ),
                      (route) => true);
                },
              text: 'Sign Up',
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.black54,
              )),
        ]));
  }

  ElevatedButton _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.black,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          minimumSize: const Size(double.infinity, 50)),
      onPressed: () async {
        // print("e mail : ${this.user!.email}");
        // print("uid ${this.user!.uid}");

        try {
          var user = await auth.signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
          if (user != null) {
            // ignore: use_build_context_synchronously
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>  Home(),
                ),
                (route) => false);
          }
        } on FirebaseAuthException catch (e) {
          print(e.code);
          switch (e.code) {
            case "wrong-password":
              return callSnackbar("Wrong password.");

            case "user-not-found":
              return callSnackbar("Wrong E Mail");
            case "too-many-requests":
              return callSnackbar("Please try a few seconds later");
            default:
          }
        }
      },
      child: Text("Sign In",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          )),
    );
  }
}
