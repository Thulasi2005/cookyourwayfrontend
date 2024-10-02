import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerProfilePage extends StatefulWidget {
  final String identifier;
  final String token;

  CustomerProfilePage({required this.identifier, required this.token});

  @override
  _CustomerProfilePageState createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  File? _profileImage;
  String _fullName = '';
  String _loyaltyPoints = '';
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _fetchUserProfile();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _fetchUserProfile() async {
    final url = 'http://10.0.2.2/get_customer_profile';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _fullName = data['full_name'] ?? 'No Name'; // Handle null
          _loyaltyPoints = data['loyalty_points']?.toString() ?? '0'; // Handle null
          _isLoading = false;
        });
      } else {
        _handleError(response.statusCode);
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch user profile: $e');
    }
  }

  void _handleError(int statusCode) {
    setState(() {
      _isLoading = false;
    });
    // You can handle different status codes here
    print('Error fetching user profile: $statusCode');
    _showErrorDialog('Error: $statusCode. Please try again.');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Profile'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: FadeTransition(
                opacity: _animation,
                child: CircleAvatar(
                  radius: 60.0,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : AssetImage('assets/images/logo.png')
                  as ImageProvider,
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _fullName.isNotEmpty ? _fullName : widget.identifier,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreen[900],
              ),
            ),
            SizedBox(height: 30),
            _buildProfileInfo('Customer ID', widget.identifier),

            _buildProfileInfo(
              'Loyalty Points',
              _loyaltyPoints.isNotEmpty ? _loyaltyPoints : '20',
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _logoutCustomer(context),
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _logoutCustomer(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/loginselection');
  }
}
