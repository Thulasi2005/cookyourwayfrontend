import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartPage extends StatefulWidget {
  final String token;

  CartPage({required this.token});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    print("Token received: ${widget.token}"); // Print the token to verify
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/cart'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': widget.token, // Token should be included here
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        List<Map<String, dynamic>> items = [];
        data.forEach((key, value) {
          for (var item in value) {
            items.add(item);
          }
        });

        setState(() {
          cartItems = items;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (error) {
      print('Error fetching cart items: $error');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }


  // Update item quantity
  Future<void> updateQuantity(int itemId, int newQuantity) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/cart/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': widget.token, // Include the token in the request body
          'item_id': itemId, // Make sure this is the correct key
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        fetchCartItems();
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }

  // Remove item from cart
  Future<void> removeItem(int itemId) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/cart/remove'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': widget.token, // Include the token in the request body
          'item_id': itemId, // Make sure this is the correct key
        }),
      );

      if (response.statusCode == 200) {
        fetchCartItems();
      } else {
        throw Exception('Failed to remove item');
      }
    } catch (error) {
      print('Error removing item: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        backgroundColor: Colors.green[800],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(child: Text('Failed to load cart items.'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['description']),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${item['price']}'),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (item['quantity'] > 1) {
                              updateQuantity(item['item_id'], item['quantity'] - 1);
                            }
                          },
                        ),
                        Text(item['quantity'].toString()),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            updateQuantity(item['item_id'], item['quantity'] + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                removeItem(item['item_id']);
              },
            ),
          );
        },
      ),
    );
  }
}
