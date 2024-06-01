import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems; // Accept selected items as a parameter
  final Function() resetCart;

  const CartPage({Key? key, required this.cartItems, required this.resetCart}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();


}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: _buildCartItems(),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${_calculateTotalCost()}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement checkout functionality
                  _checkout();
                },
                child: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      itemCount: widget.cartItems.length,
      itemBuilder: (context, index) {
        final item = widget.cartItems[index];
        return ListTile(
          title: Text(item['name']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: \$${item['price']}'),
              Text('Quantity: ${item['quantity']}'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.remove_shopping_cart),
            onPressed: () {
              _removeItemFromCart(index);
            },
          ),
        );
      },
    );
  }


  String _calculateTotalCost() {
    double totalCost = 0;
    widget.cartItems.forEach((item) {
      totalCost += (item['price'] ?? 0) * (item['quantity'] ?? 0);
    });
    return totalCost.toStringAsFixed(2);
  }

  void _checkout() {
    // Simulate fake order completion
    // Generate a fake transaction ID
    String transactionId = 'TRX${DateTime.now().millisecondsSinceEpoch}';

    // Fetch user's address and phone number from Firestore
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('users').doc(user?.uid).get().then((userData) {
      if (userData.exists) {
        // Extract user's address and phone number
        String building = userData.get('building');
        String street = userData.get('street');
        String floor = userData.get('floor');
        String apartment = userData.get('apartment');
        String phoneNumber = userData.get('phoneNumber');
        String email = userData.get('email');

        // Display order completion message with transaction ID and user's address
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Order Completed'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Transaction ID: $transactionId'),
                  SizedBox(height: 10),
                  const Text('Delivery Address:'),
                  Text('Building: $building'),
                  Text('Street: $street'),
                  Text('Floor: $floor'),
                  Text('Apartment: $apartment'),
                  const SizedBox(height: 10),
                  Text('Phone Number: $phoneNumber'),
                  Text('Email: $email'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Reset all counters to zero
                    setState(() {
                      widget.cartItems.forEach((item) {
                        item['quantity'] = 0;
                      });
                    });

                    widget.resetCart(); // Call the resetCart function passed from Home widget
                    // Clear the cart
                    widget.cartItems.clear();

                    // Pop the dialog
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // User data not found
        print('User data not found');
      }
    }).catchError((error) {
      // Error fetching user data
      print('Error fetching user data: $error');
    });
  }


  void _removeItemFromCart(int index) {
    setState(() {
      var removedItem = widget.cartItems.removeAt(index); // Remove item from widget.cartItems
      // Pass the removed item along with the updated cart items back to the previous screen
      Navigator.pop(context, {'removedItem': removedItem, 'updatedCartItems': widget.cartItems});
    });
  }

}

