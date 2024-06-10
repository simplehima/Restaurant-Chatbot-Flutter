import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> availableTables = [
    {"tableId": "1", "time": "12:00 PM", "reserved": false},
    {"tableId": "2", "time": "1:00 PM", "reserved": false},
    {"tableId": "3", "time": "7:00 PM", "reserved": false},
    {"tableId": "4", "time": "1:30 PM", "reserved": false},
    {"tableId": "5", "time": "2:00 PM", "reserved": false},
    {"tableId": "6", "time": "4:00 PM", "reserved": false},
    {"tableId": "7", "time": "5:30 PM", "reserved": false},
    {"tableId": "8", "time": "5:00 PM", "reserved": false},
    // Add more tables and times here
  ];

  @override
  void initState() {
    super.initState();
    fetchAvailableTables();
  }

  void fetchAvailableTables() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('tables').get();
      List<Map<String, dynamic>> filteredTables = [];
      for (var doc in querySnapshot.docs) {
        var table = availableTables.firstWhere((table) => table['tableId'] == doc.id, orElse: () => ({}));
        if (table.isNotEmpty) {
          filteredTables.add({
            "tableId": doc.id,
            "time": doc['time'],
            "reserved": doc['reserved'] ?? false,
            "reservedBy": doc['reservedBy'] ?? false,
          });
        }
      }

      setState(() {
        availableTables = filteredTables;
      });
    } catch (e) {
      print('Error fetching available tables: $e');
    }
  }
  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }


  void reserveTable(int index) async {
    try {
      var table = availableTables[index];
      if (table != null) {
        String? currentUserId = getCurrentUserId();
        if (currentUserId == null) {
          // Handle the case where the user is not logged in
          print('User is not logged in');
          return;
        }

        print('Current User ID: $currentUserId');
        print('Reserved By: ${table["reservedBy"]}');

        DocumentReference tableRef = _firestore.collection('tables').doc(table["tableId"]);
        if (!table["reserved"]) {
          await tableRef.set({
            'time': table["time"],
            'reserved': true,
            'reservedBy': currentUserId, // Use current user ID
            'reservationTime': DateTime.now(),
          });
          setState(() {
            availableTables[index]["reserved"] = true;
            availableTables[index]["reservedBy"] = currentUserId;
            availableTables[index]["reservationTime"] = DateTime.now();
          });
        } else if (table["reservedBy"] == currentUserId) {
          await tableRef.update({
            'reserved': false,
            'reservedBy': null,
            'reservationTime': null,
          });
          setState(() {
            availableTables[index]["reserved"] = false;
            availableTables[index]["reservedBy"] = null;
            availableTables[index]["reservationTime"] = null;
          });
        } else {
          // Handle the case where the table is reserved by another user
          print('Table is reserved by another user');
          return;
        }
      }
    } catch (e) {
      print('Error reserving table: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Page'),
      ),
      body: ListView.builder(
        itemCount: availableTables.length,
        itemBuilder: (context, index) {
          var table = availableTables[index];
          if (table != null) {
            return ListTile(
              title: Text('Table ${table["tableId"]}'),
              subtitle: Text('Time: ${table["time"]}'),
              trailing: table["reserved"]
                  ? Text('Reserved', style: TextStyle(color: Colors.red))
                  : null,
              onTap: () {
                reserveTable(index);
              },
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: ReservationPage(),
  ));
}
