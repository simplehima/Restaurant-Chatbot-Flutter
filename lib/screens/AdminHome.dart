import 'package:RCB/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  String _productImageUrl = '';
  String _productDescription = '';
  double _productPrice = 0.0;
  String _productCategory = '';
  String _productTag = '';

  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('categories').get();
      setState(() {
        _categories = snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
      });
    } catch (error) {
      print('Error loading categories: $error');
    }
  }

  void _addProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        await FirebaseFirestore.instance.collection('products').add({
          'name': _productName,
          'imageUrl': _productImageUrl,
          'description': _productDescription,
          'price': _productPrice,
          'quantity': 1, // Default quantity set to 1
          'category': _productCategory, // Add category
          'tag': _productTag, // Add tag
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully!')),
        );
        _formKey.currentState?.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Add Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Container(
        color: Color.fromRGBO(213, 152, 109, 1), // Set the background color
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 10),
              Image.asset(
                'assets/icon/ChatbotLogo.png', // Replace this with the path to your logo image
                width: 150,
                height: 150, // Adjust the width as needed
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: Colors.black), // Set label text color to black
                  errorStyle: TextStyle(color: Colors.black), // Set error text color to black
                  filled: true,
                  fillColor: Colors.white, // Set input background to white
                ),
                style: TextStyle(color: Colors.black), // Set input text color to black
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productName = value ?? '';
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Product Image URL',
                  labelStyle: TextStyle(color: Colors.black), // Set label text color to black
                  errorStyle: TextStyle(color: Colors.black), // Set error text color to black
                  filled: true,
                  fillColor: Colors.white, // Set input background to white
                ),
                style: TextStyle(color: Colors.black), // Set input text color to black
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product image URL';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productImageUrl = value ?? '';
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Product Description',
                  labelStyle: TextStyle(color: Colors.black), // Set label text color to black
                  errorStyle: TextStyle(color: Colors.black), // Set error text color to black
                  filled: true,
                  fillColor: Colors.white, // Set input background to white
                ),
                style: TextStyle(color: Colors.black), // Set input text color to black
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productDescription = value ?? '';
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Product Price',
                  labelStyle: TextStyle(color: Colors.black), // Set label text color to black
                  errorStyle: TextStyle(color: Colors.black), // Set error text color to black
                  filled: true,
                  fillColor: Colors.white, // Set input background to white
                ),
                style: TextStyle(color: Colors.black), // Set input text color to black
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productPrice = double.tryParse(value ?? '0.0') ?? 0.0;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Product Category',
                  labelStyle: TextStyle(color: Colors.black),
                  errorStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _productCategory.isNotEmpty ? _productCategory : null,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _productCategory = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a product category';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productCategory = value ?? '';
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Product Tag',
                  labelStyle: TextStyle(color: Colors.black),
                  errorStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product tag';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productTag = value ?? '';
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text(
                  'Add Product',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
