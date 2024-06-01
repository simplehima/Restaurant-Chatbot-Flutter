import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  ProfilePage({required this.uid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _streetController;
  late TextEditingController _apartmentController;
  late TextEditingController _buildingController;
  late TextEditingController _floorController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController();
    _apartmentController = TextEditingController();
    _buildingController = TextEditingController();
    _floorController = TextEditingController();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _apartmentController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('No data found.'),
            );
          }

          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

          // Initialize controllers with existing data
          _streetController.text = userData['street'] ?? '';
          _apartmentController.text = userData['apartment'] ?? '';
          _buildingController.text = userData['building'] ?? '';
          _floorController.text = userData['floor'] ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildUserInfoTile('Username', userData['username']),
                _buildUserInfoTile('Age', userData['age']),
                _buildUserInfoTile('Email', userData['email']),
                _buildUserInfoTile('Phone Number', userData['phoneNumber']),
                SizedBox(height: 20),

                // Address Information Section (Editable)
                Text(
                  'Address Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildEditableUserInfoTile('Street', userData['street'], _streetController),
                _buildEditableUserInfoTile('Apartment', userData['apartment'], _apartmentController),
                _buildEditableUserInfoTile('Building', userData['building'], _buildingController),
                _buildEditableUserInfoTile('Floor', userData['floor'], _floorController),
                SizedBox(height: 20),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    // Call a function to save the edited address information
                    _saveAddressInfo(
                      _streetController.text,
                      _apartmentController.text,
                      _buildingController.text,
                      _floorController.text,
                    );
                  },
                  child: _isLoading ? CircularProgressIndicator() : Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoTile(String title, dynamic value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value.toString()),
    );
  }

  Widget _buildEditableUserInfoTile(String title, String? value, TextEditingController controller) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: value,
        ),
      ),
    );
  }

  void _saveAddressInfo(String street, String apartment, String building, String floor) {
    if (street.isEmpty || apartment.isEmpty || building.isEmpty || floor.isEmpty) {
      _showDialog('Error', 'Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
      'street': street,
      'apartment': apartment,
      'building': building,
      'floor': floor,
    }).then((value) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Address Information Saved', 'Your address information has been updated successfully.');
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'Failed to save address information: $error');
    });
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
