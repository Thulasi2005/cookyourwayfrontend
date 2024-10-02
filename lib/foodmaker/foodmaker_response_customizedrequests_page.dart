import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// FoodCustomization model
class FoodCustomization {
  final int id;
  final String foodName;
  final int quantity;
  final String portionSize;
  final String foodDescription;
  final String priceRange;
  final String address;
  final String deliveryMethod;
  final String identifier;
  final String status;

  FoodCustomization({
    required this.id,
    required this.foodName,
    required this.quantity,
    required this.portionSize,
    required this.foodDescription,
    required this.priceRange,
    required this.address,
    required this.deliveryMethod,
    required this.identifier,
    required this.status,
  });

  factory FoodCustomization.fromJson(Map<String, dynamic> json) {
    return FoodCustomization(
      id: json['id'] ?? 0,
      foodName: json['food_name'] ?? 'Unknown',
      quantity: json['quantity'] ?? 0,
      portionSize: json['portion_size'] ?? 'Unknown',
      foodDescription: json['food_description'] ?? 'No description provided',
      priceRange: json['price_range'] ?? 'N/A',
      address: json['address'] ?? 'N/A',
      deliveryMethod: json['delivery_method'] ?? 'Unknown',
      identifier: json['identifier'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
    );
  }
}

// CustomizedRequestsPage widget
class CustomizedRequestsPage extends StatefulWidget {
  @override
  _CustomizedRequestsPageState createState() => _CustomizedRequestsPageState();
}

class _CustomizedRequestsPageState extends State<CustomizedRequestsPage> {
  late String identifier;
  late String token;
  List<FoodCustomization> requests = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    identifier = args['identifier'];
    token = args['token'];

    // Fetch customized requests from the API
    fetchCustomizedRequests();
  }

  Future<void> fetchCustomizedRequests() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.26:8000/api/response/food_customizations'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        requests = data.map((json) => FoodCustomization.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load requests')),
      );
    }
  }

  Future<void> acceptRequest(int requestId) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.26:8000/api/food_customizations/$requestId/accept'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'chef_identifier': identifier}), // Pass chef_identifier here
    );

    if (response.statusCode == 200) {
      setState(() {
        // Remove the accepted request from the list
        requests.removeWhere((request) => request.id == requestId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request accepted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request: ${response.statusCode} - ${response.body}')),
      );
    }
  }

  Future<void> declineRequest(int requestId) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.26:8000/api/food_customizations/$requestId/decline'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'chef_identifier': identifier}), // Pass chef_identifier here
    );

    if (response.statusCode == 200) {
      setState(() {
        // Remove the declined request from the list
        requests.removeWhere((request) => request.id == requestId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request declined successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline request: ${response.statusCode} - ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customized Requests'),
        backgroundColor: Colors.green[700],
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Text(
              'Customized Requests for Chef $identifier',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return _buildRequestCard(requests[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(FoodCustomization request) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request #${request.id}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Food Name: ${request.foodName}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Quantity: ${request.quantity}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Portion Size: ${request.portionSize}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Description: ${request.foodDescription}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Price Range: ${request.priceRange}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Address: ${request.address}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Delivery Method: ${request.deliveryMethod}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Identifier: ${request.identifier}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Status: ${request.status}',
              style: TextStyle(fontSize: 16, color: request.status == 'Pending' ? Colors.orange : Colors.green),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    acceptRequest(request.id); // Call accept function
                  },
                  child: Text('Accept'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    declineRequest(request.id); // Call decline function
                  },
                  child: Text('Decline'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
