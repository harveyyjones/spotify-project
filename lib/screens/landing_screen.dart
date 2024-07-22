import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_project/business/business_logic.dart';
import 'package:spotify_project/main.dart';
import 'package:spotify_project/screens/login_page.dart';
import 'package:spotify_project/screens/register_page.dart';
import 'package:spotify_project/screens/steppers.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class LandingPage extends StatefulWidget {
  LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xfff2f9ff),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4.5,
            ),
            Text(
              softWrap: true,
              "Welcome to Musee!",
              style: GoogleFonts.alata(
                textStyle: TextStyle(
                    fontSize: 66.sp,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    letterSpacing: .5),
              ),
            ),
            SizedBox(
              height: screenHeight / 55,
            ),
            Padding(
              padding: EdgeInsets.only(left: screenWidth / 33),
              child: Text(
                softWrap: true,
                "After creating an account, just play a music in Spotify and start being matched!",
                style: GoogleFonts.alata(
                  textStyle: TextStyle(
                      fontSize: 33.sp,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      letterSpacing: .5),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight / 4,
            ),
            GeneralButton("Connect to spotify", LoginPage(),
                Color.fromARGB(255, 28, 141, 60)),
            SizedBox(
              height: screenHeight / 15,
            ),
          ],
        ),
      ),
    );
  }
}

class GeneralButton extends StatelessWidget {
  BusinessLogic _businessLogic = BusinessLogic();
  GeneralButton(this.text, this.route, this.color);
  Color? color;
  String? text;
  var route;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () async {
        try {
          await _businessLogic.getAccessToken(clientId, redirectURL).then(
              (value) => _businessLogic.connectToSpotifyRemote().then((value) {
                    connected = true;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return SteppersForClients();
                      },
                    ));
                  }));
        } catch (e) {
          print("Spotify girişe izin vermedi.");
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: color ?? Colors.black,
            borderRadius: const BorderRadius.all(
              Radius.circular(30),
            )),
        width: screenWidth / 2,
        height: screenHeight / 12,
        child: Center(
          child: Text(text.toString(),
              style: GoogleFonts.poppins(
                  fontSize: 33.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ),
      ),
    );
  }
}

class LandingElement extends StatelessWidget {
  LandingElement({super.key, required this.uri});
  String uri;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CircleAvatar(
        radius: 80.sp,
        // backgroundImage: AssetImage("lib/assets/arcticmonkeys.jpg"),
        foregroundImage: AssetImage("lib/assets/${uri}.jpg"),
      ),
    );
  }
}
