import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ItemDetailsPage extends StatefulWidget {
  final int itemId;
  final String token;
  final String identifier;

  ItemDetailsPage({required this.itemId, required this.token, required this.identifier});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  Map<String, dynamic>? itemDetails;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    try {
      print('Fetching item details...');
      final response = await http.get(
        Uri.parse('http://192.168.1.26:8000/api/menu/item/${widget.itemId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      // Log the response status code and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          itemDetails = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load item details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching item details: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load item details: $error'),
      ));
    }
  }

  Future<void> addToCart() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/cart/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'item_id': widget.itemId,
          'quantity': quantity,
          'name': itemDetails!['name'],
          'description': itemDetails!['description'],
          'price': itemDetails!['price'],
          'token': widget.token, // Include the token here as required by your backend
        }),
      );

      print('Response status: ${response.statusCode}'); // Log response status
      print('Response body: ${response.body}'); // Log response body

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item added to cart!'),
        ));
      } else {
        throw Exception('Failed to add item to cart: ${response.body}'); // Include response body for debugging
      }
    } catch (error) {
      print('Error adding to cart: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add item to cart: $error'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
        backgroundColor: Colors.green[800],
      ),
      body: itemDetails == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemDetails!['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              itemDetails!['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '\$${itemDetails!['price']}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Quantity:',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: quantity,
                  onChanged: (value) {
                    setState(() {
                      quantity = value!;
                    });
                  },
                  items: List.generate(10, (index) => index + 1)
                      .map<DropdownMenuItem<int>>(
                        (int value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addToCart,
              child: Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
