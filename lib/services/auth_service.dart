import 'package:RCB/screens/home.dart';
import 'package:RCB/services/google_register_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  // Stream to listen to authentication state changes

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Login with Google
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Initialize GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Add by HimaAzab To ensure that google account is signed out so it doesn't auto sign in with last logged in email
      await googleSignIn.signOut();

      // Prompt user to select Google account
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();

      // Handle user cancellation
      if (gUser == null) return null;

      // Get authentication details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create credential with the obtained tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Return user email along with UserCredential
      return userCredential;
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error signing in with Google'),
            content: Text('$error'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return null; // Handle errors gracefully
    }
  }




  // Navigate to HomePage on successful login
  void navigateToHomePage(BuildContext context) async {
    final userCredential = await signInWithGoogle(context);
    if (userCredential != null) {
      // for debugging HimaAzab
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('User authenticated, checking registration status...'),
      //       actions: <Widget>[
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //           child: const Text('OK'),
      //         ),
      //       ],
      //     );
      //   },
      // );
      // Check if user is already registered
      bool isRegistered = await isUserRegistered(userCredential.user!.email!);
      if (isRegistered) {
        // for debugging HimaAzab
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: const Text('you are already registered'),
        //       actions: <Widget>[
        //         TextButton(
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //           },
        //           child: const Text('OK'),
        //         ),
        //       ],
        //     );
        //   },
        // );
        // User is registered, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('You are not registered !'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        // User is not registered, navigate to registration screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>
              RegistrationGoogle(userEmail: userCredential.user!.email)),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Failed to authenticate please try again'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

// Method to check if user is already registered lo mesh registered
  Future<bool> isUserRegistered(String userEmail) async {
    // Query Firestore to check if user with given email exists
    var snapshot = await FirebaseFirestore.instance.collection('users').doc(
        userEmail).get();
    return snapshot.exists;
  }
}