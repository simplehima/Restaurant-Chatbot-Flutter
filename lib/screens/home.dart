import 'package:RCB/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import FirebaseFirestore
import 'package:RCB/screens/chatbot.dart'; // Make sure to import the Chatbot screen or other screens you want to navigate to

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
// Add this variable to hold the logged-in user
  late String _username = ''; // Add this variable to hold the username

  @override
  void initState() {
    super.initState();
    // Get the current user
    _loadUsername();// Load the username
  }

  Future<void> _loadUsername() async {
    try {
      // Fetch the user document from Firestore using the UID
      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      // Retrieve the username from the document data
      setState(() {
        _username = snapshot.data()?['username'] ?? ''; // Use the username field from the document
      });
    } catch (error) {
      print('Error loading username: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent going back to login screen if logged in
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome $_username'), // Display the user's username
        ),
        drawer: _buildDrawer(context),
        body: const Center(
          child: Text('Welcome to RC Bot!'),
        ),
      ),
    );
  }

  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chatbot'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Handle the settings navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Handle the about navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              signOut(context); //logout action
            },
          ),
        ],
      ),
    );
  }
}
