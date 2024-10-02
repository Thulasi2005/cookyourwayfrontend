import 'package:flutter/material.dart';
import 'customer/customer_sign_up_page.dart';
import 'foodmaker/food_maker_sign_up_page.dart';

class RegistrationSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCAF1BC), // Updated background color
      appBar: AppBar(
        title: Text(
          'User Registration Selection',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50), // Spacing at the top
              Image.asset(
                'assets/images/logo.png', // Ensure the logo path is correct
                height: MediaQuery.of(context).size.height * 0.2, // Responsive image size
              ),
              SizedBox(height: 30), // Spacing between the logo and text
              Text(
                'Register As',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightGreen[900], // Darker green text for better contrast
                ),
              ),
              SizedBox(height: 30), // Spacing between text and buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerSignUpPage()),
                    ); // Navigate to the customer registration page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    foregroundColor: Colors.lightGreen[900], // Text color
                    padding: EdgeInsets.symmetric(vertical: 20), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    ),
                    side: BorderSide( // Add border around the button
                      color: Colors.lightGreen[900]!, // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Text(
                    'Customer',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Spacing between buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoodMakerSignUpPage()),
                    ); // Navigate to the food maker registration page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    foregroundColor: Colors.lightGreen[900], // Text color
                    padding: EdgeInsets.symmetric(vertical: 20), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    ),
                    side: BorderSide( // Add border around the button
                      color: Colors.lightGreen[900]!, // Border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Text(
                    'Food Maker',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}
