import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/product_model.dart';
import 'cart.dart';


class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<ChatbotScreen> {
  List<Map<String, dynamic>> messages = [];
  TextEditingController _controller = TextEditingController();
  late ScrollController _scrollController;
  late Map<String, Product> products = {}; // Change to a map
  List<Product> cart = [];
  int _cartItemCount = 0;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
      Map<String, Product> loadedProducts = {}; // Initialize as a map
      snapshot.docs.forEach((doc) {
        Product product = Product.fromFirestore(doc);
        loadedProducts[product.id] = product; // Use product ID as the key
      });
      setState(() {
        products = loadedProducts;
      });
    } catch (e) {
      _showAlertDialog(context, 'Error', 'Failed to load products: $e');
    }
  }
  void addToCart(Product product) {
    setState(() {
      cart.add(product);
      _cartItemCount++;
      addMessage('${product.name} has been added to your cart.');
    });

    // Convert the list of Product objects to the required format
    List<Map<String, dynamic>> cartItems = cart.map((product) {
      return {
        'name': product.name,
        'price': product.price,
        'quantity': 1, // Assuming the initial quantity is 1
      };
    }).toList();

    // Pass the converted cartItems list to the CartPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartItems: cartItems, resetCart: resetCart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessagesScreen(messages: messages, scrollController: _scrollController),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.brown,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: 45.0, right: 10.0), // Adjust the top and right padding as needed
        child: Align(
          alignment: Alignment.topRight,
          child: FloatingActionButton(
            onPressed: () {
              // Convert the list of Product objects to the required format
              List<Map<String, dynamic>> cartItems = cart.map((product) {
                return {
                  'name': product.name,
                  'price': product.price,
                  'quantity': 1, // Assuming the initial quantity is 1
                };
              }).toList();

              // Pass the converted cartItems list to the CartPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(cartItems: cartItems, resetCart: resetCart),
                ),
              );
            },
            child: Icon(Icons.shopping_cart),
            backgroundColor: Colors.brown,
          ),
        ),
      ),
    );
  }
  void resetCart() {
    setState(() {
      cart.clear();
      _cartItemCount = 0;
    });
  }


  void sendMessage(String text) {
    if (text.isEmpty) {
      _showAlertDialog(context, 'Empty Message', 'Please type in a message first.');
      return;
    }

    setState(() {
      addMessage(text, isUserMessage: true);
    });

    // Check if the user's input is an exact match to any of the function names
    if (text.trim() == 'addToCartByQuery' ||
        text.trim() == 'findResponse' ||
        text.trim() == 'findProduct') {
      setState(() {
        addMessage('Sorry, I don\'t understand that. Please provide a valid message.');
      });
      return;
    }

    String? response = findResponse(text);
    if (response != null) {
      setState(() {
        addMessage(response);
      });
    } else {
      Product? product = findProduct(text);

      if (product != null) {
        setState(() {
          addMessage(
            '${product.name}\nPrice: \$${product.price}\nDescription: ${product.description}',
            imageUrl: product.imageUrl, // Display the product image if available
          );
        });
      } else {
        addToCartByQuery(text);
      }
    }

    _scrollToBottom();
  }


  void removeFromCart(Product product) {
    setState(() {
      cart.removeWhere((item) => item.id == product.id);
      addMessage('${product.name} has been removed from your cart.');
    });
  }

  void addToCartByQuery(String text) {
    // Define the list of queries and corresponding product IDs
    Map<String, String> queries = {
      // Double Burger
      'i want to buy double burger': '3E6afgB0KLdCdoG8Cp9w',
      'can i have double burger': '3E6afgB0KLdCdoG8Cp9w',
      'add double burger to my cart': '3E6afgB0KLdCdoG8Cp9w',
      'i want double burger': '3E6afgB0KLdCdoG8Cp9w',
      'i want to order double burger': '3E6afgB0KLdCdoG8Cp9w',

      // Medium Done Burger
      'i want to buy medium done burger': 'CJl1YFGRva6n2OFsxeGS',
      'can i have medium done burger': 'CJl1YFGRva6n2OFsxeGS',
      'add medium done burger to my cart': 'CJl1YFGRva6n2OFsxeGS',
      'i want medium done burger': 'CJl1YFGRva6n2OFsxeGS',
      'i want to order medium done burger': 'CJl1YFGRva6n2OFsxeGS',

      // Single Burger
      'i want to buy single burger': 'RyEJ8XqK5QJNUOu7pgdT',
      'can i have single burger': 'RyEJ8XqK5QJNUOu7pgdT',
      'add single burger to my cart': 'RyEJ8XqK5QJNUOu7pgdT',
      'i want single burger': 'RyEJ8XqK5QJNUOu7pgdT',
      'i want to order single burger': 'RyEJ8XqK5QJNUOu7pgdT',

      // Pineapple Juice
      'i want to buy pineapple juice': '6UGCrog6xh9iIZCuq6Hb',
      'can i have pineapple juice': '6UGCrog6xh9iIZCuq6Hb',
      'add pineapple juice to my cart': '6UGCrog6xh9iIZCuq6Hb',
      'i want pineapple juice': '6UGCrog6xh9iIZCuq6Hb',
      'i want to order pineapple juice': '6UGCrog6xh9iIZCuq6Hb',

      // Orange Juice
      'i want to buy orange juice': 'hfTFve6QYMeMGvmLvwBa',
      'can i have orange juice': 'hfTFve6QYMeMGvmLvwBa',
      'add orange juice to my cart': 'hfTFve6QYMeMGvmLvwBa',
      'i want orange juice': 'hfTFve6QYMeMGvmLvwBa',
      'i want to order orange juice': 'hfTFve6QYMeMGvmLvwBa',

      // Cranberry Juice
      'i want to buy cranberry juice': 'oGb2o6Wy0iC9h3HGBEu6',
      'can i have cranberry juice': 'oGb2o6Wy0iC9h3HGBEu6',
      'add cranberry juice to my cart': 'oGb2o6Wy0iC9h3HGBEu6',
      'i want cranberry juice': 'oGb2o6Wy0iC9h3HGBEu6',
      'i want to order cranberry juice': 'oGb2o6Wy0iC9h3HGBEu6',

      // Salmon Dish
      'i want to buy salmon dish': '9Y1ezAHrVrWCUdgjfMn0',
      'can i have salmon dish': '9Y1ezAHrVrWCUdgjfMn0',
      'add salmon dish to my cart': '9Y1ezAHrVrWCUdgjfMn0',
      'i want salmon dish': '9Y1ezAHrVrWCUdgjfMn0',
      'i want to order salmon dish': '9Y1ezAHrVrWCUdgjfMn0',

      // 6 Pieces of Shrimp in One Dish
      'i want to buy 6 pieces of shrimp in one dish': 'Fon4lcJ9B7lYE6ZL1WXl',
      'can i have 6 pieces of shrimp in one dish': 'Fon4lcJ9B7lYE6ZL1WXl',
      'add 6 pieces of shrimp in one dish to my cart': 'Fon4lcJ9B7lYE6ZL1WXl',
      'i want 6 pieces of shrimp in one dish': 'Fon4lcJ9B7lYE6ZL1WXl',
      'i want to order 6 pieces of shrimp in one dish': 'Fon4lcJ9B7lYE6ZL1WXl',

      // Cray Fish Dish
      'i want to buy cray fish dish': 'fKTdkU2PQ1ZA3YIDsQYU',
      'can i have cray fish dish': 'fKTdkU2PQ1ZA3YIDsQYU',
      'add cray fish dish to my cart': 'fKTdkU2PQ1ZA3YIDsQYU',
      'i want cray fish dish': 'fKTdkU2PQ1ZA3YIDsQYU',
      'i want to order cray fish dish': 'fKTdkU2PQ1ZA3YIDsQYU',

      // Beef Bacon Sandwich
      'i want to buy beef bacon sandwich': 'D7ndDTMatnlSwBzo6jMb',
      'can i have beef bacon sandwich': 'D7ndDTMatnlSwBzo6jMb',
      'add beef bacon sandwich to my cart': 'D7ndDTMatnlSwBzo6jMb',
      'i want beef bacon sandwich': 'D7ndDTMatnlSwBzo6jMb',
      'i want to order beef bacon sandwich': 'D7ndDTMatnlSwBzo6jMb',

      // Cheese with Avocado Toast
      'i want to buy cheese with avocado toast': 'Piy20zDW7yZUdEMR3QGd',
      'can i have cheese with avocado toast': 'Piy20zDW7yZUdEMR3QGd',
      'add cheese with avocado toast to my cart': 'Piy20zDW7yZUdEMR3QGd',
      'i want cheese with avocado toast': 'Piy20zDW7yZUdEMR3QGd',
      'i want to order cheese with avocado toast': 'Piy20zDW7yZUdEMR3QGd',

      // Cheese Sandwich
      'i want to buy cheese sandwich': 'ViV3WKIRatEKWCHM1TW9',
      'can i have cheese sandwich': 'ViV3WKIRatEKWCHM1TW9',
      'add cheese sandwich to my cart': 'ViV3WKIRatEKWCHM1TW9',
      'i want cheese sandwich': 'ViV3WKIRatEKWCHM1TW9',
      'i want to order cheese sandwich': 'ViV3WKIRatEKWCHM1TW9',

      // Alfredo Sauce Pasta
      'i want to buy alfredo sauce pasta': 'LNJrDPzs6uBgPHcJLTZQ',
      'can i have alfredo sauce pasta': 'LNJrDPzs6uBgPHcJLTZQ',
      'add alfredo sauce pasta to my cart': 'LNJrDPzs6uBgPHcJLTZQ',
      'i want alfredo sauce pasta': 'LNJrDPzs6uBgPHcJLTZQ',
      'i want to order alfredo sauce pasta': 'LNJrDPzs6uBgPHcJLTZQ',

      // Shrimp Basil Pasta
      'i want to buy shrimp basil pasta': 'cl3Oc8lG22oS8d3QYXee',
      'can i have shrimp basil pasta': 'cl3Oc8lG22oS8d3QYXee',
      'add shrimp basil pasta to my cart': 'cl3Oc8lG22oS8d3QYXee',
      'i want shrimp basil pasta': 'cl3Oc8lG22oS8d3QYXee',
      'i want to order shrimp basil pasta': 'cl3Oc8lG22oS8d3QYXee',

      // Taleggio Mushroom Pizza
      'i want to buy taleggio mushroom pizza': 'uDwNcCzFxsIF99WNWo0w',
      'can i have taleggio mushroom pizza': 'uDwNcCzFxsIF99WNWo0w',
      'add taleggio mushroom pizza to my cart': 'uDwNcCzFxsIF99WNWo0w',
      'i want taleggio mushroom pizza': 'uDwNcCzFxsIF99WNWo0w',
      'i want to order taleggio mushroom pizza': 'uDwNcCzFxsIF99WNWo0w',

      // Tomato Onion Flatbread Pizza
      'i want to buy tomato onion flatbread pizza': 'VffDyQqG5hTXTQflaRkE',
      'can i have tomato onion flatbread pizza': 'VffDyQqG5hTXTQflaRkE',
      'add tomato onion flatbread pizza to my cart': 'VffDyQqG5hTXTQflaRkE',
      'i want tomato onion flatbread pizza': 'VffDyQqG5hTXTQflaRkE',
      'i want to order tomato onion flatbread pizza': 'VffDyQqG5hTXTQflaRkE',

      // Pizza Napoletana
      'i want to buy pizza napoletana': 'gpDByh8XqS9uLGssJQHi',
      'can i have pizza napoletana': 'gpDByh8XqS9uLGssJQHi',
      'add pizza napoletana to my cart': 'gpDByh8XqS9uLGssJQHi',
      'i want pizza napoletana': 'gpDByh8XqS9uLGssJQHi',
      'i want to order pizza napoletana': 'gpDByh8XqS9uLGssJQHi',

      // Shrimp Pizza
      'i want to buy shrimp pizza': 'xYfHX93OIV7XFeBDF7b2',
      'can i have shrimp pizza': 'xYfHX93OIV7XFeBDF7b2',
      'add shrimp pizza to my cart': 'xYfHX93OIV7XFeBDF7b2',
      'i want shrimp pizza': 'xYfHX93OIV7XFeBDF7b2',
      'i want to order shrimp pizza': 'xYfHX93OIV7XFeBDF7b2',
    };

    // Convert user query to lowercase for case-insensitive matching
    text = text.toLowerCase();

    // Check if the user's message matches any of the queries
    for (var query in queries.keys) {
      if (text.contains(query)) {
        String productId = queries[query]!;
        Product? product = products[productId];
        if (product != null) {
          addToCart(product);
          return;
        }
      }
    }

    // If no match is found, display an error message
    setState(() {
      addMessage('Sorry, I don\'t understand that.');
    });
  }


  void _scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }


  String? findResponse(String userQuery) {
    // Convert user query to lowercase for case-insensitive matching
    userQuery = userQuery.toLowerCase();

    // Define a map of queries and corresponding responses
    Map<String, String> queryResponses = {
      'what are your working hours': 'Our working hours are from 12 AM to 1 AM.',
      'what is the opening hours': 'Our working hours are from 12 AM to 1 AM.',
      'what is the operating hours': 'Our operating hours are from 12 AM to 1 AM.',
      'what is the delivery time': 'Our delivery time is from 12 AM to 1 AM.',
      'when will the order arrive': 'Your order will arrive in 30 to 60 minutes.',
      'how long the order expected to arrive': 'Your order is expected to arrive in 30 to 60 minutes.',
      'what is the expected time for order to arrive': 'The expected time for your order to arrive is 30 to 60 minutes.',
      'why is the order being late': 'We apologize because we are very busy.',
      'why is my order too late': 'Sorry for the delay in the order due to pressure.',
      'view cart': 'Here is your cart:',
      'show me my cart': 'Here is your cart:',
      'what\'s in my cart': 'Here is your cart:',
    };
    // Iterate through query responses to check if any match the user query
    for (var query in queryResponses.keys) {
      if (userQuery.contains(query.toLowerCase())) {
        if (queryResponses[query]!.contains('cart')) {
          viewCart();
          return null; // Prevent duplicate messages
        }
        return queryResponses[query];
      }
    }
    // If no predefined response is found, return null
    return null;
  }

  Product? findProduct(String userQuery) {
    // Convert user query to lowercase for case-insensitive matching
    userQuery = userQuery.toLowerCase();

    // Define a map of keywords and corresponding actions
    Map<String, String> queryKeywords = {
      //======================================
      //========= Burger Category=============
      // double burger
      //'double burger': '3E6afgB0KLdCdoG8Cp9w',
      'tell me more about double burger': '3E6afgB0KLdCdoG8Cp9w',
      'how much is the double burger sandwich': '3E6afgB0KLdCdoG8Cp9w',
      'how much does the double burger cost': '3E6afgB0KLdCdoG8Cp9w',
      'what are the ingredients of double burger ': '3E6afgB0KLdCdoG8Cp9w',
      'what are the double burger components ': '3E6afgB0KLdCdoG8Cp9w',
      'double burger ingredients please ': '3E6afgB0KLdCdoG8Cp9w',

      // Medium Done Burger
      //'Medium done burger': 'CJl1YFGRva6n2OFsxeGS',
      'tell me more about Medium Done burger': 'CJl1YFGRva6n2OFsxeGS',
      'how much is the Medium Done burger sandwich': 'CJl1YFGRva6n2OFsxeGS',
      'how much does the Medium Done burger cost': 'CJl1YFGRva6n2OFsxeGS',
      'what are the ingredients of Medium Done burger ': 'CJl1YFGRva6n2OFsxeGS',
      'what are the Medium Done components ': 'CJl1YFGRva6n2OFsxeGS',
      'Medium Done burger ingredients please ': 'CJl1YFGRva6n2OFsxeGS',

      // single Burger
      //'single burger': 'RyEJ8XqK5QJNUOu7pgdT',
      'tell me more about Single Burger': 'RyEJ8XqK5QJNUOu7pgdT',
      'how much is the Single Burger sandwich': 'RyEJ8XqK5QJNUOu7pgdT',
      'how much does the Single Burger cost': 'RyEJ8XqK5QJNUOu7pgdT',
      'what are the ingredients of Single Burger ': 'RyEJ8XqK5QJNUOu7pgdT',
      'what are the Single Burger components ': 'RyEJ8XqK5QJNUOu7pgdT',
      'single Burger ingredients please ': 'RyEJ8XqK5QJNUOu7pgdT',

      //======= End of Burger Category========
      //======================================
      //======================================
      //========= Juice Category==============
      // pineapple juice
      //'pineapple juice': '6UGCrog6xh9iIZCuq6Hb',
      'price of the pineapple juice': '6UGCrog6xh9iIZCuq6Hb',
      'how much is the pineapple juice': '6UGCrog6xh9iIZCuq6Hb',
      'which size is the pineapple juice': '6UGCrog6xh9iIZCuq6Hb',
      'what is the size of the pineapple juice': '6UGCrog6xh9iIZCuq6Hb',

      // Orange Juice
     // 'orange juice': 'hfTFve6QYMeMGvmLvwBa',
      'price of the Orange Juice': 'hfTFve6QYMeMGvmLvwBa',
      'how much is the Orange Juice': 'hfTFve6QYMeMGvmLvwBa',
      'which size is the Orange Juice': 'hfTFve6QYMeMGvmLvwBa',
      'what is the size of the Orange Juice': 'hfTFve6QYMeMGvmLvwBa',

      // Cranberry Juice
     // 'cranberry juice': 'oGb2o6Wy0iC9h3HGBEu6',
      'price of the Cranberry  juice': 'oGb2o6Wy0iC9h3HGBEu6',
      'how much is the Cranberry  juice': 'oGb2o6Wy0iC9h3HGBEu6',
      'which size is the Cranberry  juice': 'oGb2o6Wy0iC9h3HGBEu6',
      'what is the size of the Cranberry  juice': 'oGb2o6Wy0iC9h3HGBEu6',

      //======= End of Juice Category=========
      //======================================
      //======================================
      //========= Seafood Category============
      // Salmon Dish
      //'salmon dish': '9Y1ezAHrVrWCUdgjfMn0',
      'tell me more about salmon dish': '9Y1ezAHrVrWCUdgjfMn0',
      'how much is the salmon dish': '9Y1ezAHrVrWCUdgjfMn0',
      'how much does the salmon dish cost': '9Y1ezAHrVrWCUdgjfMn0',
      'what are the ingredients of salmon dish ': '9Y1ezAHrVrWCUdgjfMn0',
      'what are the salmon dish components ': '9Y1ezAHrVrWCUdgjfMn0',
      'salmon dish ingredients please ': '9Y1ezAHrVrWCUdgjfMn0',

      // 6 pieces of shrimp in one dish
      //'6 pieces of shrimp in one dish': 'Fon4lcJ9B7lYE6ZL1WXl',
      'tell me more about 6 pieces of shrimp dish': 'Fon4lcJ9B7lYE6ZL1WXl',
      'how much is the 6 pieces of shrimp dish': 'Fon4lcJ9B7lYE6ZL1WXl',
      'how much does the 6 pieces of shrimp dish cost': 'Fon4lcJ9B7lYE6ZL1WXl',
      'what are the ingredients of 6 pieces of shrimp ': 'Fon4lcJ9B7lYE6ZL1WXl',
      'what are the 6 pieces of shrimp components ': 'Fon4lcJ9B7lYE6ZL1WXl',
      '6 pieces of shrimp dish ingredients please ': 'Fon4lcJ9B7lYE6ZL1WXl',

      // Cray Fish Dish
     // 'cray fish dish': 'fKTdkU2PQ1ZA3YIDsQYU',
      'tell me more about Cray Fish Dish': 'fKTdkU2PQ1ZA3YIDsQYU',
      'how much is the Cray Fish Dish': 'fKTdkU2PQ1ZA3YIDsQYU',
      'how much does the Cray Fish Dish cost': 'fKTdkU2PQ1ZA3YIDsQYU',
      'what are the ingredients of Cray Fish Dish ': 'fKTdkU2PQ1ZA3YIDsQYU',
      'what are the Cray Fish Dish components ': 'fKTdkU2PQ1ZA3YIDsQYU',
      'Cray Fish Dish ingredients please ': 'fKTdkU2PQ1ZA3YIDsQYU',

      //======= End of Seafood Category=======
      //======================================
      //======================================
      //========= Sandwiches Category=========
      // Beef Bacon Sandwich
     // 'beef bacon sandwich': 'D7ndDTMatnlSwBzo6jMb',
      'tell me more about Beef Bacon Sandwich': 'D7ndDTMatnlSwBzo6jMb',
      'how much is the Beef Bacon Sandwich': 'D7ndDTMatnlSwBzo6jMb',
      'how much does the Beef Bacon Sandwich cost': 'D7ndDTMatnlSwBzo6jMb',
      'what are the ingredients of Beef Bacon Sandwich ': 'D7ndDTMatnlSwBzo6jMb',
      'what are the Beef Bacon Sandwich components ': 'D7ndDTMatnlSwBzo6jMb',
      'Beef Bacon Sandwich ingredients please ': 'D7ndDTMatnlSwBzo6jMb',

      // Cheese with avocado toast
     // 'cheese with avocado toast':'D7ndDTMatnlSwBzo6jMb',
      'tell me more about Cheese with avocado toast': 'Piy20zDW7yZUdEMR3QGd',
      'how much is the Cheese with avocado toast': 'Piy20zDW7yZUdEMR3QGd',
      'how much does the Cheese with avocado toast cost': 'Piy20zDW7yZUdEMR3QGd',
      'what are the ingredients of Cheese with avocado toast ': 'Piy20zDW7yZUdEMR3QGd',
      'what are the Cheese with avocado toast components ': 'Piy20zDW7yZUdEMR3QGd',
      'Cheese with avocado toast ingredients please ': 'Piy20zDW7yZUdEMR3QGd',

      // Cheese Sandwich
      //'cheese sandwich': 'ViV3WKIRatEKWCHM1TW9',
      'tell me more about Cheese sandwich': 'ViV3WKIRatEKWCHM1TW9',
      'how much is the Cheese sandwich': 'ViV3WKIRatEKWCHM1TW9',
      'how much does the Cheese sandwich cost': 'ViV3WKIRatEKWCHM1TW9',
      'what are the ingredients of Cheese sandwich ': 'ViV3WKIRatEKWCHM1TW9',
      'what are the Cheese sandwich components ': 'ViV3WKIRatEKWCHM1TW9',
      'Cheese sandwich ingredients please ': 'ViV3WKIRatEKWCHM1TW9',


      //======= End of Sandwiches Category=======
      //======================================
      //======================================
      //========= Pasta Category==============
      // Alfredo Sauce Pasta
     // 'alfredo sauce pasta': 'LNJrDPzs6uBgPHcJLTZQ',
      'tell me more about Alfredo Sauce Pasta Dish': 'LNJrDPzs6uBgPHcJLTZQ',
      'how much is the Alfredo Sauce Pasta Dish': 'LNJrDPzs6uBgPHcJLTZQ',
      'how much does the Alfredo Sauce Pasta Dish cost': 'LNJrDPzs6uBgPHcJLTZQ',
      'what are the ingredients of Alfredo Sauce Pasta Dish ': 'LNJrDPzs6uBgPHcJLTZQ',
      'what are the Alfredo Sauce Pasta Dish components ': 'LNJrDPzs6uBgPHcJLTZQ',
      'Alfredo Sauce Pasta Dish ingredients please ': 'LNJrDPzs6uBgPHcJLTZQ',

      // Shrimp Basil Pasta
      //'shrimp basil pasta': 'cl3Oc8lG22oS8d3QYXee',
      'tell me more about shrimp basil Pasta Dish': 'cl3Oc8lG22oS8d3QYXee',
      'how much is the shrimp basil Pasta Dish': 'cl3Oc8lG22oS8d3QYXee',
      'how much does the shrimp basil Pasta Dish cost': 'cl3Oc8lG22oS8d3QYXee',
      'what are the ingredients of shrimp basil Pasta Dish ': 'cl3Oc8lG22oS8d3QYXee',
      'what are the shrimp basil Pasta Dish components ': 'cl3Oc8lG22oS8d3QYXee',
      'shrimp basil Pasta Dish ingredients please ': 'cl3Oc8lG22oS8d3QYXee',

      //======= End of Pasta Category=========
      //======================================
      //======================================
      //========= Pizza Category==============
      // Taleggio Mushroom Pizza
      //'taleggio mushroom pizza': 'uDwNcCzFxsIF99WNWo0w',
      'tell me more about Taleggio Mushroom Pizza': 'uDwNcCzFxsIF99WNWo0w',
      'how much is the Taleggio Mushroom Pizza': 'uDwNcCzFxsIF99WNWo0w',
      'how much does the Taleggio Mushroom Pizza cost': 'uDwNcCzFxsIF99WNWo0w',
      'what are the ingredients of Taleggio Mushroom Pizza ': 'uDwNcCzFxsIF99WNWo0w',
      'what are the Taleggio Mushroom Pizza components ': 'uDwNcCzFxsIF99WNWo0w',
      'Taleggio Mushroom Pizza ingredients please ': 'uDwNcCzFxsIF99WNWo0w',

      // Tomato Onion Flatbread Pizza
     // 'tomato onion flatbread pizza': 'VffDyQqG5hTXTQflaRkE',
      'tell me more about Tomato Onion Flatbread Pizza': 'VffDyQqG5hTXTQflaRkE',
      'how much is the Tomato Onion Flatbread Pizza': 'VffDyQqG5hTXTQflaRkE',
      'how much does the Tomato Onion Flatbread Pizza cost': 'VffDyQqG5hTXTQflaRkE',
      'what are the ingredients of Tomato Onion Flatbread Pizza ': 'VffDyQqG5hTXTQflaRkE',
      'what are the Tomato Onion Flatbread Pizza components ': 'VffDyQqG5hTXTQflaRkE',
      'Tomato Onion Flatbread Pizza ingredients please ': 'VffDyQqG5hTXTQflaRkE',

      // Pizza Napoletana
     // 'pizza Napoletana': 'gpDByh8XqS9uLGssJQHi',
      'tell me more about pizza Napoletana': 'gpDByh8XqS9uLGssJQHi',
      'how much is the pizza Napoletana': 'gpDByh8XqS9uLGssJQHi',
      'how much does the pizza Napoletana cost': 'gpDByh8XqS9uLGssJQHi',
      'what are the ingredients of pizza Napoletana ': 'gpDByh8XqS9uLGssJQHi',
      'what are the pizza Napoletana components ': 'gpDByh8XqS9uLGssJQHi',
      'pizza Napoletana ingredients please ': 'gpDByh8XqS9uLGssJQHi',

      // Shrimp pizza
     // 'shrimp pizza': 'xYfHX93OIV7XFeBDF7b2',
      'tell me more about Shrimp pizza': 'xYfHX93OIV7XFeBDF7b2',
      'how much is the Shrimp pizza': 'xYfHX93OIV7XFeBDF7b2',
      'how much does the Shrimp pizza cost': 'xYfHX93OIV7XFeBDF7b2',
      'what are the ingredients of Shrimp pizza ': 'xYfHX93OIV7XFeBDF7b2',
      'what are the Shrimp pizza components ': 'xYfHX93OIV7XFeBDF7b2',
      'Shrimp pizza ingredients please ': 'xYfHX93OIV7XFeBDF7b2',


      //======= End of Pizza Category=========
      //======================================
      //======================================
    };

    // Iterate through query keywords to check if any match the user query
    for (var keyword in queryKeywords.keys) {
      if (userQuery.contains(keyword.toLowerCase())) {
        String productId = queryKeywords[keyword]!;
        return products[productId];
      }
    }

    // If no specific product is found, return null
    return null;
  }


  void addMessage(String message, {String? imageUrl, bool isUserMessage = false}) {
    setState(() {
      messages.add({'message': message, 'imageUrl': imageUrl, 'isUserMessage': isUserMessage});
    });
  }


  void viewCart() {
    if (cart.isEmpty) {
      addMessage('Your cart is empty.');
    } else {
      String cartDetails = 'Your cart contains:\n';
      for (var product in cart) {
        cartDetails += '${product.name} - \$${product.price}\n';
      }
      addMessage(cartDetails);
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
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class MessagesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final ScrollController scrollController;
  const MessagesScreen({Key? key, required this.messages, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.separated(
      controller: scrollController,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: messages[index]['isUserMessage']
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(
                      messages[index]['isUserMessage'] ? 0 : 20,
                    ),
                    topLeft: Radius.circular(
                      messages[index]['isUserMessage'] ? 20 : 0,
                    ),
                  ),
                  color: messages[index]['isUserMessage']
                      ? Colors.brown
                      : Colors.brown.shade900.withOpacity(0.8),
                ),
                constraints: BoxConstraints(maxWidth: w * 2 / 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(messages[index]['message']),
                    if (messages[index]['imageUrl'] != null)
                      Image.network(
                        messages[index]['imageUrl'],
                        width: 100, // Adjust the width as needed
                        height: 100, // Adjust the height as needed
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, i) => Padding(padding: EdgeInsets.only(top: 10)),
      itemCount: messages.length,
    );
  }
}
