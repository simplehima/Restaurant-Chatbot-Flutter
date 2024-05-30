import 'package:RCB/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:RCB/services/firebase_options.dart';
import 'screens/splash_screen.dart'; // Import the SplashScreen
import 'screens/home.dart'; // Import the Home screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding is initialized before calling Firebase.initializeApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase connection established'); // Print confirmation message
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMBot',
      theme: ThemeData(brightness: Brightness.dark),
      home: SplashScreen(), // Show SplashScreen as the initial screen
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}