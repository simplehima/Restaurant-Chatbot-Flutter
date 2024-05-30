import 'package:RCB/component/my_button.dart';
import 'package:RCB/component/my_textfield.dart';
import 'package:RCB/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart';


class RegistrationGoogle extends StatefulWidget {
  final String? userEmail;
  const RegistrationGoogle({super.key, this.userEmail});

  @override
  _RegistrationGoogleState createState() => _RegistrationGoogleState();
}

class _RegistrationGoogleState extends State<RegistrationGoogle> {
  late String userEmail;
  @override
  void initState() {
    super.initState();
    // Initialize userEmail here instead of during declaration to pass it 3al4n ageb el email we a7oto fe firestore
    userEmail = widget.userEmail ?? '';
  }
  // text editing controllers
  // text editing controllers
  final usernameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final ageController = TextEditingController();
  final streetController = TextEditingController();
  final apartmentController = TextEditingController();
  final floorController = TextEditingController();
  final buildingController = TextEditingController();

  // navigate to the second registration screen method
  void navigateToHomePage(BuildContext context) {
    // Pass email to RegistrationPage2
    Navigator.push(
      context,
      MaterialPageRoute(builder: (
          context) => const Home()),
    );
  }


  bool isValidPhoneNumber(String phoneNumber) {
    // Regular expression for Egyptian phone numbers with optional country code
    final regex = RegExp(r'^(\+20)?(010|011|012|015)\d{8}$');

    // Check if the phone number matches the regular expression
    return regex.hasMatch(phoneNumber.trim());
  }

  bool isValidAge(String age) {
    int? ageValue = int.tryParse(age);
    return ageValue != null && ageValue >= 18;
  }

  bool isValidEmail(String email) {
    // Regular expression for email validation
    RegExp regex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
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
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  bool validateFields(BuildContext context) {
    if (usernameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        ageController.text.isEmpty ||
        streetController.text.isEmpty ||
        apartmentController.text.isEmpty ||
        floorController.text.isEmpty ||
        buildingController.text.isEmpty) {
      _showAlertDialog(context, 'Empty Fields', 'Please fill in all fields.');
      return false;
    }


    if (!isValidPhoneNumber(phoneNumberController.text)) {
      _showAlertDialog(context, 'Invalid Phone Number', 'Please enter a valid Egyptian phone number.');
      return false;
    }

    if (!isValidAge(ageController.text)) {
      _showAlertDialog(context, 'Invalid Age', 'You must be 18 years or older to register.');
      return false;
    }

    return true;
  }

  void register(BuildContext context) async {
    try {
      // Retrieve field values
      String username = usernameController.text;
      String phoneNumber = phoneNumberController.text;
      String age = ageController.text;
      String street = streetController.text;
      String apartment = apartmentController.text;
      String floor = floorController.text;
      String building = buildingController.text;

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'uid': user?.uid,
        'email': userEmail,
        'username': username,
        'phoneNumber': phoneNumber,
        'age': age,
        'street': street,
        'apartment': apartment,
        'floor': floor,
        'building': building,
      });

      // If registration successful, navigate to next page
      navigateToHomePage(context);
    } catch (error) {
      // Handle registration errors
      print(error.toString());
      if (error is FirebaseAuthException) {
        // Handle specific error cases
        switch (error.code) {
          case 'invalid-phone-number':
            _showAlertDialog(context, 'Invalid Phone Number', 'Please enter a valid phone number.');
            break;
          case 'requires-recent-login':
          // Prompt user to reauthenticate
            break;
          default:
            _showAlertDialog(context, 'Registration Failed', 'An error occurred during registration.');
        }
      } else {
        _showAlertDialog(context, 'Registration Failed', 'An error occurred during registration.');
      }
    }
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
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),

                // registration message
                const Text(
                  'Complete Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24, // Increased font size for a more modern look
                    fontWeight: FontWeight.bold, // Making the text bold
                    fontFamily: 'Roboto', // You can change the font family as needed
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

                      // phone number textfield
                      MyTextField(
                        controller: phoneNumberController,
                        hintText: 'Phone Number',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),

                      // age textfield
                      MyTextField(
                        controller: ageController,
                        hintText: 'Age',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),

                      // street textfield
                      MyTextField(
                        controller: streetController,
                        hintText: 'Street',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),

                      // apartment textfield
                      MyTextField(
                        controller: apartmentController,
                        hintText: 'Apartment',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),

                      // floor textfield
                      MyTextField(
                        controller: floorController,
                        hintText: 'Floor',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),

                      // building textfield
                      MyTextField(
                        controller: buildingController,
                        hintText: 'Building',
                        obscureText: false,
                      ),
                      const SizedBox(height: 20),
                      // Next button
                      MyButton(
                        text: "Register",
                        onTap: () => register(context),
                      ),
                      const SizedBox(height: 20),
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
}