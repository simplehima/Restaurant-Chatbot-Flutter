import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:RCB/screens/home.dart';
import 'package:RCB/screens/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToCorrectScreen();
  }

  _navigateToCorrectScreen() async {
    // Wait for a short duration to display the splash screen
    await Future.delayed(Duration(seconds: 3));

    // Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, navigate to the Home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      // User is not logged in, navigate to the Login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Image.asset('assets/icon/ChatbotLogolarge.png'), // Display the splash image
      ),
    );
  }
}
