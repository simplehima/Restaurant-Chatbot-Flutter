import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    String email = emailController.text.trim();

    // Validate input
    if (email.isEmpty) {
      _showAlertDialog(context, 'Empty Email', 'Please enter your email.');
      return;
    }

    try {
      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      // Show success message
      _showAlertDialog(context, 'Email Sent', 'Password reset instructions have been sent to your email.');

      // Clear the email field
      emailController.clear();
    } catch (error) {
      // Log error for debugging
      print('Error occurred while sending password reset email: $error');

      // Show an error alert dialog with more details about the error
      _showAlertDialog(context, 'Error', 'An error occurred while sending password reset email. Please try again.');
    }
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(213, 152, 109, 1),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Roboto',
          ),

        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password',
            style: TextStyle(color: Colors.white),),
          backgroundColor: const Color.fromRGBO(213, 152, 109, 1),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // logo
              Image.asset(
                'assets/icon/ChatbotLogo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 1,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Email text field
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Enter your email',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reset password button
                    ElevatedButton(
                      onPressed: () => sendPasswordResetEmail(context),
                      child: const Text('Send Reset Email'),
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
}