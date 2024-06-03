import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/product_model.dart';

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
    );
  }

  void sendMessage(String text) {
    if (text.isEmpty) {
      _showAlertDialog(context, 'Empty Message', 'Please type in a message first.');
      return;
    }

    // Fetch product based on user input
    Product? product = findProduct(text);

    if (product != null) {
      setState(() {
        addMessage(text, isUserMessage: true); // Add the user's message
        addMessage(
          '${product.name}\nPrice: \$${product.price}\nDescription: ${product.description}',
          imageUrl: product.imageUrl, // Pass the image URL
        );
      });
    } else {
      setState(() {
        addMessage(text, isUserMessage: true); // Add the user's message
        addMessage('Sorry, I don\'t understand that.');
      });
    }

    _scrollToBottom();
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

  Product? findProduct(String userQuery) {
    // Convert user query to lowercase for case-insensitive matching
    userQuery = userQuery.toLowerCase();

    // Define a map of keywords and corresponding actions
    Map<String, String> queryKeywords = {
      //======================================
      //========= Burger Category=============
      // double burger
      'double burger': '3E6afgB0KLdCdoG8Cp9w',
      'tell me more about double burger': '3E6afgB0KLdCdoG8Cp9w',

      // Medium Done Burger
      'medium done burger': 'CJl1YFGRva6n2OFsxeGS',

      // Single Burger
      'single burger': 'RyEJ8XqK5QJNUOu7pgdT',

      //======= End of Burger Category========
      //======================================
      //======================================
      //========= Juice Category==============
      // pineapple juice
      'pineapple juice': '6UGCrog6xh9iIZCuq6Hb',
      // Orange Juice
      'orange juice': 'hfTFve6QYMeMGvmLvwBa',
      // Cranberry Juice
      'cranberry juice': 'oGb2o6Wy0iC9h3HGBEu6',
      //======= End of Juice Category=========
      //======================================
      //======================================
      //========= SeaFood Category============
      // Salmon Dish
      'salmon dish': '9Y1ezAHrVrWCUdgjfMn0',
      // 6 pices of shrimp in one dish
      '6 pices of shrimp in one dish': 'Fon4lcJ9B7lYE6ZL1WXl',
      // Cray Fish Dish
      'cray fish dish': 'fKTdkU2PQ1ZA3YIDsQYU',
      //======= End of SeaFood Category=======
      //======================================
      //======================================
      //========= Sandwiches Category=========
      // Beef Bacon Sandwich
      'beef bacon sandwich': 'D7ndDTMatnlSwBzo6jMb',
      // Cheese with avocado toast
      'cheese with avocado toast': 'Piy20zDW7yZUdEMR3QGd',
      // Cheese Sandwich
      'cheese sandwich': 'ViV3WKIRatEKWCHM1TW9',
      //======= End of Sandwiches Category=======
      //======================================
      //======================================
      //========= Pasta Category==============
      // Alfredo Sauce Pasta
      'alfredo sauce pasta': 'LNJrDPzs6uBgPHcJLTZQ',
      // Shrimp Basil Pasta
      'shrimp basil pasta': 'cl3Oc8lG22oS8d3QYXee',
      // Taleggio Mushroom Pizza
      'taleggio mushroom pizza': 'uDwNcCzFxsIF99WNWo0w',
      //======= End of Pasta Category=========
      //======================================
      //======================================
      //========= Pizza Category==============
      // Tomato Onion Flatbread Pizza
      'tomato onion flatbread pizza': 'VffDyQqG5hTXTQflaRkE',
      // Pizza Napoletana
      'pizza napoletana': 'gpDByh8XqS9uLGssJQHi',
      // Shrimp Pasta
      'shrimp pasta': 'xYfHX93OIV7XFeBDF7b2',
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
