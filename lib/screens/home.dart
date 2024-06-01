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
  List<Map<String, dynamic>> _cartItems = [];

  void _resetCart() {
    setState(() {
      _cartItems.clear();
      _selectedQuantities.clear();
      _cartItemCount = 0;
    });
  }


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


  void _updateCart(String productId, int quantityChange, Map<String, dynamic> product) {
    final existingIndex = _cartItems.indexWhere((item) => item['productId'] == productId);
    if (existingIndex != -1) {
      setState(() {
        // Update existing item quantity
        _cartItems[existingIndex]['quantity'] += quantityChange;
        // Remove item if quantity becomes 0
        if (_cartItems[existingIndex]['quantity'] == 0) {
          _cartItems.removeAt(existingIndex);
        }
      });
    } else {
      setState(() {
        // Add new item to cart
        _cartItems.add({
          'productId': productId,
          'name': product['name'],
          'price': product['price'],
          'quantity': quantityChange,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total number of items in the cart
    int totalCartItems = _selectedQuantities.values.fold(0, (sum, quantity) => sum + quantity);

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
                      MaterialPageRoute(builder: (context) => CartPage(cartItems: _cartItems,  resetCart: _resetCart,)),
                    ).then((data) {
                      if (data != null) {
                        setState(() {
                          // Extract removed item and updated cart items from the returned data
                          var removedItem = data['removedItem'];
                          var updatedCartItems = data['updatedCartItems'];

                          if (removedItem != null && updatedCartItems != null) {
                            // Check if the removed item exists in the cart items
                            var existingItem = removedItem != null && removedItem['productId'] != null
                                ? _cartItems.firstWhere(
                                  (item) => item['productId'] == removedItem['productId'],
                              orElse: () => <String, dynamic>{}, // Provide an empty map as the default value
                            )
                                : <String, dynamic>{};

                            if (existingItem != null) {
                              // Update the item counter and the cart counter
                              _selectedQuantities[removedItem['productId']] = 0;
                              _cartItemCount -= (existingItem['quantity'] ?? 0) as int;

                            }
                            // Update the cart items with the updated cart items
                            _cartItems = updatedCartItems;
                          }
                        });
                      }
                    });
                  },
                ),
                if (totalCartItems > 0) // Display the total number of items in the cart
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 9,
                      child: Text(
                        '$totalCartItems',
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
              backgroundColor: Colors.brown, // Customize the FAB background color
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
  void _updateCartLocally(String productId, int quantityChange, Map<String, dynamic> product) {
    setState(() {
      int selectedQuantity = _selectedQuantities[productId] ?? 0;
      selectedQuantity += quantityChange;
      if (selectedQuantity < 0) {
        selectedQuantity = 0;
      }
      _selectedQuantities[productId] = selectedQuantity;
      _updateCart(productId, quantityChange, product);
    });
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
    return FutureBuilder<QuerySnapshot>(
      future: _selectedCategory != 'All'
          ? FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: _selectedCategory)
          .get()
          : FirebaseFirestore.instance.collection('products').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
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
    double productPrice = product['price'] ?? 0.0;

    return StatefulBuilder(
      builder: (context, setState) {
        int selectedQuantity = _selectedQuantities[productId] ?? 0;
        double totalCost = selectedQuantity * productPrice;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    product['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
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
                            _updateCartLocally(productId, -1, product);
                          },
                        ),
                        Text(selectedQuantity.toString()),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _updateCartLocally(productId, 1, product);
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
        );
      },
    );
  }
}

