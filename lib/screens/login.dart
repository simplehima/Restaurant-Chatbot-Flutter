import 'package:RCB/component/my_button.dart';
import 'package:RCB/component/my_textfield.dart';
import 'package:RCB/component/square_tile.dart';
import 'package:RCB/screens/Registration_Page.dart';
import 'package:RCB/screens/home.dart';
import 'package:RCB/services/auth_service.dart';
import 'package:RCB/services/pasword_reset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'AdminHome.dart';


class LoginPage extends StatelessWidget {
  LoginPage({super.key,});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }


  // sign user in method
  Future<void> signUserIn(BuildContext context) async {
    String email = usernameController.text.trim();
    String password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showAlertDialog(context, 'Empty Fields', 'Please fill in all fields.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showAlertDialog(context, 'Invalid Email', 'Please enter a valid email address.');
      return;
    }

    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch the user document from Firestore using the user's UID
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid) // Use the user's UID obtained after login
          .get();

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
    } catch (error) {
      // Handle login errors
      print('Error during login: $error');
      if (error is FirebaseAuthException) {
        print('FirebaseAuthException: ${error.code}');
        if (error.code == 'user-not-found') {
          _showAlertDialog(context, 'User Not Found', 'No user found with this email.');
        } else if (error.code == 'wrong-password') {
          _showAlertDialog(context, 'Incorrect Password', 'The password is incorrect.');
        } else {
          _showAlertDialog(context, 'Login Failed', 'An error occurred during login.');
        }
      } else {
        print('Other error occurred during login');
        _showAlertDialog(context, 'Login Failed', 'An error occurred during login.');
      }
    }
  }

  // navigate to registration screen method
  void navigateToRegistrationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(213, 152, 109, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // logo
                Image.asset(
                  'assets/icon/ChatbotLogo.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),

                // welcome back, you've been missed!
                const Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),

                // Container with white background
                Container(
                  width: MediaQuery.of(context).size.width * 1, // Adjust width as needed
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // username textfield
                      MyTextField(
                        controller: usernameController,
                        hintText: 'Username',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),

                      // password textfield
                      MyTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),

                      // forgot password
                      GestureDetector(
                        onTap: () {
                          // Navigate to forgot password screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PasswordResetPage()),
                          );
                        },
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // sign-in button
                      MyButton(
                        text: "Sign In",
                        onTap: () => signUserIn(context),
                      ),
                      const SizedBox(height: 20),

                      // Or continue with divider
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 1.5,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Divider(
                              thickness: 1.5,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Google and Apple sign-in buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SquareTile(
                            onTap: () {
                              // Call navigateToHomePage from AuthService
                              //AuthService().signInWithGoogle();
                              AuthService().navigateToHomePage(context);
                            },
                            imagePath: 'assets/icon/google.png', ),
                          const SizedBox(width: 10),

                        ],
                      ),
                      const SizedBox(height: 20),

                      // Not a member? Register now
                      GestureDetector(
                        onTap: () => navigateToRegistrationScreen(context),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Not a member? ',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'Register now',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to show alert dialog with message
  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
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