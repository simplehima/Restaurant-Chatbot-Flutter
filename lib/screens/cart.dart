import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = []; // Store cart items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: _buildCartItems(), // Display cart items
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
                child: Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return ListTile(
          title: Text(item['name']),
          subtitle: Text('Price: \$${item['price']}'),
          trailing: IconButton(
            icon: Icon(Icons.remove_shopping_cart),
            onPressed: () {
              // Implement remove item from cart functionality
              _removeItemFromCart(index);
            },
          ),
        );
      },
    );
  }

  String _calculateTotalCost() {
    double totalCost = 0;
    _cartItems.forEach((item) {
      totalCost += (item['price'] ?? 0) * (item['quantity'] ?? 0);
    });
    return totalCost.toStringAsFixed(2);
  }

  void _checkout() {
    // Implement checkout functionality here
    print('Checkout');
  }

  void _removeItemFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }
}
