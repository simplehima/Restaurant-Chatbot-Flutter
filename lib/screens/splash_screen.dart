import 'package:RCB/screens/AdminHome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Fetch the user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Safely extract the isAdmin field
        dynamic isAdminField = userDoc.data()?['isAdmin'];
        bool isAdmin = false;
        if (isAdminField is bool) {
          isAdmin = isAdminField;
        } else if (isAdminField is String) {
          isAdmin = isAdminField.toLowerCase() == 'true';
        }

        if (isAdmin) {
          // User is an admin, navigate to the AdminPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
          );
        } else {
          // User is not an admin, navigate to the Home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      } else {
        // User document does not exist, navigate to the Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
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
