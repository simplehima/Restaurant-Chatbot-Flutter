import 'package:RCB/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:RCB/component/my_button.dart';
import 'package:RCB/component/my_textfield.dart';

class RegistrationPage1 extends StatelessWidget {
  RegistrationPage1({Key? key}) : super(key: key);


  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final ageController = TextEditingController();
  final streetController = TextEditingController();
  final apartmentController = TextEditingController();
  final floorController = TextEditingController();
  final buildingController = TextEditingController();


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
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        ageController.text.isEmpty ||
        streetController.text.isEmpty ||
        apartmentController.text.isEmpty ||
        floorController.text.isEmpty ||
        buildingController.text.isEmpty) {
      _showAlertDialog(context, 'Empty Fields', 'Please fill in all fields.');
      return false;
    }

    if (!isValidEmail(emailController.text)) {
      _showAlertDialog(context, 'Invalid Email', 'Please enter a valid email address.');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showAlertDialog(context, 'Password Too Short', 'Please enter a password with at least 6 characters.');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showAlertDialog(context, 'Passwords Do Not Match', 'Please make sure your passwords match.');
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



  void navigateToRegistrationPage2(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationPage2(
          username: usernameController.text,
          email: emailController.text,
          password: passwordController.text,
          phoneNumber: phoneNumberController.text,
          age: int.tryParse(ageController.text) ?? 0,
          street: streetController.text,
          apartment: apartmentController.text,
          floor: floorController.text,
          building: buildingController.text,
        ),
      ),
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
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),

                // registration message
                const Text(
                  'Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 20),

                // Container with white background
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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

                      // email textfield
                      MyTextField(
                        controller: emailController,
                        hintText: 'Email',
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

                      // confirm password textfield
                      MyTextField(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true,
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
                        text: "Next",
                        onTap: () {
                          if (validateFields(context)) {
                            navigateToRegistrationPage2(context);
                          }
                        },
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

class RegistrationPage2 extends StatelessWidget {
  final String username;
  final String email;
  final String password;
  final String phoneNumber;
  final int age;
  final String street;
  final String apartment;
  final String floor;
  final String building;

  const RegistrationPage2({
    required this.username,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.age,
    required this.street,
    required this.apartment,
    required this.floor,
    required this.building,
  });

  void submitRegistration(BuildContext context) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user's UID
      String uid = userCredential.user!.uid;
      User? user = FirebaseAuth.instance.currentUser;
      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': user?.uid,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'age': age,
        'street': street,
        'apartment': apartment,
        'floor': floor,
        'building': building,
      });

      // Show registration success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      // Navigate to home screen upon successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (
            context) => const Home()), // Replace HomeScreen with your actual home screen widget
      );

    } catch (error) {
      // Show registration failure message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
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
          'Registration - Step 2',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 20),

        // Container with white background
        Container(
        width: MediaQuery.of(context).size.width * 0.9,
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    // Display the collected data
    Text('Username: $username',
      style: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    ),
    ),
    const SizedBox(height: 10),
    Text('Email: $email',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    ),
    const SizedBox(height: 10),
    Text('Phone Number: $phoneNumber',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    ),
    const SizedBox(height: 10),
    Text('Age: $age',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    ),
    const SizedBox(height: 10),
    Text('Street: $street',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    ),
    const SizedBox(height: 10),
    Text('Apartment: $apartment',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    ),
    const SizedBox(height: 10),
    Text('Floor: $floor',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    ),
    const SizedBox(height: 10),
    Text('Building: $building',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    ),
    const SizedBox(height: 20),

    // Add a button for submitting the registration
      MyButton(
        text: "Submit",
        onTap: () => submitRegistration(context),
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
