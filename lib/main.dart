import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:spotify_project/business/Spotify_Logic/constants.dart';
import 'package:spotify_project/business/business_logic.dart';
import 'package:spotify_project/screens/landing_screen.dart';
import 'package:spotify_project/screens/steppers.dart';
import 'package:spotify_project/widgets/bottom_bar.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:spotify_project/business/Spotify_Logic/Models/top_playlists.dart';
import 'package:spotify_project/business/Spotify_Logic/services/fetch_playlists.dart';

import 'screens/quick_match_screen.dart';

import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAeu7KYeIdCUZ8DZ0oCjjzK15rVdilwKO8",
      appId: "1:985372741706:android:c92c014fe473d59aff96b3",
      messagingSenderId: "985372741706",
      projectId: "musee-285eb",
      storageBucket: "gs://musee-285eb.appspot.com",
    ),
  );

  // Initialize Spotify connection
  final businessLogic = BusinessLogic();
  await businessLogic.getAccessToken('b56ad9c2cf434b748466bb6adbb511ca', 'https://www.rubycurehealthtourism.com/');
  await businessLogic.connectToSpotifyRemote();

  try {
    Stripe.publishableKey = 'pk_test_51PvbvsP9evS8B1HZYQovuCob0GKGlKrqLFumzno3e8ozZFmEdFmcekKmaH6k8v9CHzw5nCn6b0GrxxfP24q5tF4o00jZbPSGuY';
    await Stripe.instance.applySettings();
  } catch (e) {
    if (e is MissingPluginException) {
      print('Stripe plugin not available: ${e.message}');
      // Handle the case where Stripe is not available
    } else {
      print('Error initializing Stripe: $e');
    }
  }

  runApp(MyApp(businessLogic: businessLogic));
}

class MyApp extends StatelessWidget {
  final BusinessLogic businessLogic;
  const MyApp({Key? key, required this.businessLogic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(720, 1080),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Musee',
        home: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Home(); //Home(businessLogic: businessLogic,);
            } else {
              return LandingPage();
            }
          },
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  // final BusinessLogic businessLogic;
  final businessLogic;
  Home({Key? key, this.businessLogic  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          bool connected = snapshot.data?.connected ?? false;
          return Scaffold(
            bottomNavigationBar: BottomBar(selectedIndex: 0),
           body: Everything(connected: connected),
          );
        },
      ),
    );
  }
}

class Everything extends StatefulWidget {
  final bool connected;
  const Everything({Key? key, required this.connected}) : super(key: key);

  @override
  State<Everything> createState() => _EverythingState();
}

class _EverythingState extends State<Everything> {
  late Future<List<Playlist>> futurePlaylists;
  bool _isPaymentComplete = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    futurePlaylists = fetchPlaylists();
  }

  Future<List<Playlist>> fetchPlaylists() async {
    SpotifyServiceForPlaylists spotifyService = SpotifyServiceForPlaylists(accessToken);
    return await spotifyService.fetchPlaylists();
  }

  Future<void> _handlePayment() async {
    setState(() => _loading = true);
    try {
      final clientSecret = await _createPaymentIntent();
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      setState(() => _isPaymentComplete = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<String> _createPaymentIntent() async {
    // TODO: Implement server-side logic to create a payment intent
    await Future.delayed(const Duration(seconds: 2));
    return 'mock_client_secret';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color.fromARGB(255, 234, 243, 252)),
        ListView(
          padding: const EdgeInsets.all(8),
          children: [
            SizedBox(height: ScreenUtil().setHeight(72)),
            _buildQuickMatchButton(),
            if (widget.connected) _buildCurrentTrackInfo(),
            _buildPlaylistsList(),
          ],
        ),
        if (_loading)
          Container(
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildQuickMatchButton() {
    return GestureDetector(
       onTap: _navigateToQuickMatch, // _isPaymentComplete ? _navigateToQuickMatch : _handlePayment,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(36)),
        child: Container(
          width: ScreenUtil().setWidth(480),
          height: ScreenUtil().setHeight(108),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            color: _isPaymentComplete ? const Color.fromARGB(255, 92, 190, 214) : Colors.grey,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(66, 66, 66, 0.244),
                spreadRadius: 1,
                offset: Offset(2, 10),
                blurRadius: 10,
              )
            ],
          ),
          child: Center(
            child: Text(
              _isPaymentComplete ? "Quick Match" : "Pay to Unlock",
              style: GoogleFonts.alata(
                textStyle: TextStyle(
                  fontSize: 48.sp,
                  color: Colors.white,
                  letterSpacing: .5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Steps to implement Stripe payment:
  // 1. Set up a Stripe account and get your publishable key
  // 2. Add the flutter_stripe package to your pubspec.yaml
  // 3. Initialize Stripe in your main() function
  // 4. Create a backend server to handle payment intents
  // 5. Implement the payment flow in your app

  // Example of initializing Stripe (add this to your main() function):
  // Stripe.publishableKey = 'your_publishable_key_here';
  // await Stripe.instance.applySettings();

  Future<void> handlePayment() async {
    setState(() => _loading = true);
    try {
      // Create a payment intent on your server
      final paymentIntentResult = await createPaymentIntent('1', 'PLN');
      
      // Confirm the payment with Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentResult['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Your App Name',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      
      // Payment successful
      setState(() => _isPaymentComplete = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    // This should be implemented on your backend server
    // For testing, you can use a local server or a service like Firebase Cloud Functions
    const String url = 'https://your-backend-url.com/create-payment-intent';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'amount': amount,
        'currency': currency,
      },
    );
    return json.decode(response.body);
  }

  void _navigateToQuickMatch() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const QuickMatchesScreen()));
  }

  Widget _buildCurrentTrackInfo() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (context, snapshot) {
        final track = snapshot.data?.track;
        if (track == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            '${track.artist.name} - ${track.name}',
            style: const TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsList() {
    return FutureBuilder<List<Playlist>>(
      future: futurePlaylists,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No playlists found'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final playlist = snapshot.data![index];
              return ListTile(
                leading: playlist.images.isNotEmpty
                    ? Image.network(playlist.images.first.url)
                    : null,
                title: Text(playlist.name),
                subtitle: Text(playlist.description),
              );
            },
          );
        }
      },
    );
  }
}
