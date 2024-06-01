import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:RCB/screens/login.dart';
import 'package:RCB/screens/chatbot.dart';
import 'package:RCB/screens/cart.dart'; // Import the Cart screen

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String _username = ''; // Add this variable to hold the username
  int _cartItemCount = 0; // Variable to track cart items count
  Map<String, int> _selectedQuantities = {};
  List<String> _categories = [];
  late String _selectedCategory = 'All'; // Default category to 'All'



  @override
  void initState() {
    super.initState();
    // Get the current user
    _loadUsername(); // Load the username
    _loadCategories(); // Load product categories
  }

  Future<void> _loadUsername() async {
    try {
      // Fetch the user document from Firestore using the UID
      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      // Retrieve the username from the document data
      setState(() {
        _username = snapshot.data()?['username'] ??
            ''; // Use the username field from the document
      });
    } catch (error) {
      print('Error loading username: $error');
    }
  }

  Future<void> _loadCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('categories').get();
      setState(() {
        _categories = ['All']; // Initialize with 'All' category
        _categories.addAll(snapshot.docs.map((doc) => doc.data()['name'] as String).toList());
      });
    } catch (error) {
      print('Error loading categories: $error');
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
          actions: [
            // Add a cart button in the opposite side of the sandwich menu button
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    // Navigate to the Cart screen when cart button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  },
                ),
                if (_cartItemCount > 0) // Display the number of items selected
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 9,
                      child: Text(
                        '$_cartItemCount',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        backgroundColor: Color.fromRGBO(213, 152, 109, 1),
        // Set the background color
        body: Column(
          children: [
            _buildFilter(),
            Expanded(
              child: _buildProductGrid(),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                // Navigate to the Chatbot screen when the FAB is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatbotScreen()),
                );
              },
              child: Icon(Icons.chat), // Add the chatbot icon to the FAB
              backgroundColor: Colors
                  .brown, // Customize the FAB background color
            ),
            SizedBox(height: 10),
          ],
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
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(213, 152, 109,
                  1), // Change this color to match your background color
            ),
            child: Image.asset(
              'assets/icon/ChatbotLogo.png',
              // Replace this with the path to your logo image
              width: 100, // Adjust the width as needed
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

  Widget _buildFilter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        hint: Text('Filter by Category'),
        items: _categories.map((category) {
          return DropdownMenuItem
            (
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _selectedCategory != 'All'
          ? FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: _selectedCategory)
          .snapshots()
          : FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data?.docs ?? [];

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 4, // Adjust the aspect ratio as needed
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index].data() as Map<String, dynamic>;
            final productId = products[index].id;
            return _buildProductTile(productId, product);
          },
          padding: const EdgeInsets.all(10),
        );
      },
    );
  }

  Widget _buildProductTile(String productId, Map<String, dynamic> product) {
    int selectedQuantity = _selectedQuantities[productId] ?? 0;
    double productPrice = product['price'] ?? 0.0;
    double totalCost = selectedQuantity * productPrice;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners for the whole card
      ),
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), // Rounded corners for the top left
                  topRight: Radius.circular(20), // Rounded corners for the top right
                ),
                child: Image.network(
                  product['imageUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200, // Adjust the height as needed
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${productPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_selectedQuantities[productId] != null &&
                                  _selectedQuantities[productId]! > 0) {
                                _selectedQuantities[productId] =
                                    _selectedQuantities[productId]! - 1;
                                _cartItemCount--; // Decrease cart item count
                              }
                            });
                          },
                        ),
                        Text(selectedQuantity.toString()),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              if (_selectedQuantities[productId] != null) {
                                _selectedQuantities[productId] =
                                    _selectedQuantities[productId]! + 1;
                              } else {
                                _selectedQuantities[productId] = 1;
                              }
                              _cartItemCount++; // Increase cart item count
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total Cost: \$${totalCost.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

