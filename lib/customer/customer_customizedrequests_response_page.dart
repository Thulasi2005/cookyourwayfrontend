import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'customer_payment_page.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> _customizations = []; // Store fetched customizations
  bool _isLoading = true; // Loading state
  bool _hasError = false; // Error state
  String? token;
  String identifier = 'User'; // Default identifier
  final Color backgroundColor = Color(0xFFCAF1BC); // Background color

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch arguments passed to this page
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    if (args != null) {
      token = args['token'];
      identifier = args['identifier'] ?? 'User';

      // Fetch customizations when the token and args are available
      _fetchCustomizations();
    }
  }

  Future<void> _fetchCustomizations() async {
    if (token != null) {
      // API call to fetch customizations
      final response = await http.get(
        Uri.parse('http://192.168.1.26:8000/api/response/food_customizations'),
        headers: {
          'Authorization': 'Bearer $token', // Token authentication
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _customizations = data; // Store fetched data
          _isLoading = false; // Stop loading
          _hasError = false; // Reset error state
        });
      } else {
        // Handle API error
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        print('Failed to load customizations: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCAF1BC), Color(0xFFE0F7FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              )
                  : _hasError
                  ? Center(
                child: Text(
                  'Failed to load orders. Please try again later.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
                  : _buildOrderList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(100.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: AppBar(
          title: Text('Your Orders', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent, // Transparent AppBar
          elevation: 0, // No shadow
          centerTitle: true,
          toolbarHeight: 100, // Increased height
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $identifier!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800], // Dark brown for text
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Here are your current food customizations:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.brown[600], // Lighter brown for subtext
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _customizations.length,
              itemBuilder: (context, index) {
                final customization = _customizations[index];
                final status = customization['status'];
                final isAccepted = status == 'Accepted';

                return _buildOrderCard(customization, isAccepted);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic customization, bool isAccepted) {
    final status = customization['status'];

    return Card(
      color: Colors.green[600], // Dark green card background
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          'Order #${customization['id']}',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Food: ${customization['food_name']}', style: TextStyle(color: Colors.white)),
            Text('Quantity: ${customization['quantity']}', style: TextStyle(color: Colors.white)),
            Text('Portion Size: ${customization['portion_size']}', style: TextStyle(color: Colors.white)),
            Text('Price Range: ${customization['price_range']}', style: TextStyle(color: Colors.white)),
            Text('Delivery Method: ${customization['delivery_method']}', style: TextStyle(color: Colors.white)),
            Text('Address: ${customization['address']}', style: TextStyle(color: Colors.white)),
            Text('Description: ${customization['food_description']}', style: TextStyle(color: Colors.white)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAccepted ? Colors.green[200] : Colors.orangeAccent,
              ),
            ),
            // Show the Pay Now button only for accepted orders
            if (isAccepted)
              ElevatedButton(
                onPressed: () {
                  final id = customization['id'];

                  if (id == null) {
                    print('Error: customization id is null.');
                    return; // Prevent further execution
                  }

                  // Ensure that the id is a String
                  String idString;
                  if (id is String) {
                    idString = id; // Already a string
                  } else if (id is int) {
                    idString = id.toString(); // Convert int to string
                  } else {
                    print('Error: customization id is not a string or int. It is a ${id.runtimeType}.');
                    return; // Handle unexpected type
                  }

                  _handlePayment(idString); // Pass the id as a string
                },
                child: Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400], // Button color
                ),
              ),
          ],
        ),
        onTap: () {
          // Handle order tap
          Navigator.pushNamed(context, '/orderDetails', arguments: {
            'identifier': identifier,
            'token': token,
            'orderId': customization['id'].toString(),
          });
        },
      ),
    );
  }


  void _handlePayment(String orderId) {
    // Check if the orderId is null or empty
    if (orderId.isEmpty) {
      // Handle empty case if necessary
      print('Error: Received empty orderId in _handlePayment.');
      return;
    }

    // Proceed with payment processing using the valid orderId
    print('Processing payment for orderId: $orderId');

    // Find the customization by order ID
    final customization = _customizations.firstWhere(
          (c) => c['id'].toString() == orderId,
      orElse: () => null, // Provide a default value if not found
    );

    // Check if customization is null
    if (customization == null) {
      print('Error: No customization found for orderId: $orderId');
      return;
    }

    // Convert price_range to a double and handle potential null
    double amount = double.tryParse(customization['price_range']?.toString() ?? '0.0') ?? 0.0;

    // Navigate to PaymentPage without request_id
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          amount: amount, // Pass the amount as a double
          orderId: orderId, // Pass the orderId as well
        ),
      ),
    );
  }




  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: 'Tracking',
        ),
      ],
      currentIndex: 1, // Highlight the 'Orders' tab
      selectedItemColor: Colors.green, // Selected item color
      onTap: (index) {
        // Handle navigation based on the selected tab
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
          // Stay on orders page
            break;
          case 2:
            Navigator.pushNamed(context, '/profile');
            break;
          case 3:
            Navigator.pushNamed(context, '/tracking');
            break;
        }
      },
    );
  }
}
