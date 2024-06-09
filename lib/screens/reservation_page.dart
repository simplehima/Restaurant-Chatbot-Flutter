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
    {"tableId": "3", "time": "7:00 PM", "reserved": true},
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
      List<Map<String, dynamic>> tablesFromFirebase = querySnapshot.docs.map((doc) {
        return {
          "tableId": doc.id,
          "time": doc['time'],
          "reserved": doc['reserved'] ?? false,
        };
      }).toList();

      setState(() {
        availableTables.addAll(tablesFromFirebase);
      });
    } catch (e) {
      print('Error fetching available tables: $e');
    }
  }

  void reserveTable(int index) async {
    try {
      // Get a reference to the table document
      DocumentReference tableRef = _firestore.collection('tables').doc(availableTables[index]["tableId"]);

      if (!availableTables[index]["reserved"]) {
        // Reserve the table if it's not already reserved
        await tableRef.set({
          'time': availableTables[index]["time"],
          'reserved': true,
          'reservedBy': 'UserXYZ', // Replace with actual user ID
          'reservationTime': DateTime.now(),
        });

        print("Table ${availableTables[index]["tableId"]} reserved.");
        setState(() {
          availableTables[index]["reserved"] = true;
        });
      } else {
        // Cancel the reservation if it's already reserved
        DocumentSnapshot docSnapshot = await tableRef.get();
        if (docSnapshot.exists) {
          await tableRef.update({
            'reserved': false,
            'reservedBy': null,
            'reservationTime': null,
          });

          print("Table ${availableTables[index]["tableId"]} reservation cancelled.");
          setState(() {
            availableTables[index]["reserved"] = false;
          });
        } else {
          print("Document for Table ${availableTables[index]["tableId"]} not found.");
          // Handle the case where the document doesn't exist
          // For example, you can display a message to the user
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
          return ListTile(
            title: Text('Table ${availableTables[index]["tableId"]}'),
            subtitle: Text('Time: ${availableTables[index]["time"]}'),
            trailing: availableTables[index]["reserved"]
                ? Text('Reserved', style: TextStyle(color: Colors.red))
                : null,
            onTap: () {
              try {
                reserveTable(index);
              } catch (e) {
                print('Error tapping on table: $e');
              }
            },
          );
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