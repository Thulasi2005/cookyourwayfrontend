import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodMakerPaymentsPage extends StatefulWidget {
  final String identifier; // Added identifier
  final String token; // Added token

  FoodMakerPaymentsPage({required this.identifier, required this.token});

  @override
  _FoodMakerPaymentsPageState createState() => _FoodMakerPaymentsPageState();
}

class _FoodMakerPaymentsPageState extends State<FoodMakerPaymentsPage> {
  List<dynamic> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    final String url = 'http://192.168.1.26:8000/api/paymentss'; // Replace with your API URL

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${widget.token}', // Assuming you are using token-based authentication
      });

      if (response.statusCode == 200) {
        setState(() {
          _payments = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        // Handle error
        throw Exception('Failed to load payments');
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching payments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _payments.length,
          itemBuilder: (context, index) {
            final payment = _payments[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment ID: ${payment['id']}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow(Icons.receipt, 'Order ID', payment['order_id']),
                    _buildInfoRow(Icons.attach_money, 'Amount', '\$${payment['amount']}'),
                    _buildInfoRow(Icons.payment, 'Payment Method', payment['payment_method']),
                    _buildInfoRow(Icons.person, 'Card Holder', payment['card_holder_name']),
                    _buildInfoRow(Icons.credit_card, 'Card Number', payment['card_number']),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper function to build a row with an icon and text
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          SizedBox(width: 10),
          Text(
            '$title:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
