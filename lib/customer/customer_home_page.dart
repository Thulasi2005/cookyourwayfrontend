import 'package:flutter/material.dart';

class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0; // Tracks the selected index for bottom navigation
  String identifier = 'User'; // Move identifier and token to class-level
  String token = '';

  // Method to handle navigation when a bottom nav item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic based on selected index
    switch (index) {
      case 0: // Home
        Navigator.pushNamed(context, '/customerhomepage', arguments: {'identifier': identifier, 'token': token});
        break;
      case 1: // Orders
        Navigator.pushNamed(context, '/customercustomizedresponse', arguments: {'identifier': identifier, 'token': token});
        break;
      case 2: // Profile
        Navigator.pushNamed(context, '/customerprofile', arguments: {
          'identifier': identifier,
          'token': token,
        });
        break;
      case 3: // Help
        Navigator.pushNamed(context, '/customerhelp', arguments: {'identifier': identifier, 'token': token});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extracting arguments passed from the LoginPage
    final args = ModalRoute.of(context)?.settings.arguments;

    // Safely casting arguments
    if (args is Map<String, String>) {
      identifier = args['identifier'] ?? 'User'; // Assign value to class-level variable
      token = args['token'] ?? '';

      return Scaffold(
        backgroundColor: Color(0xFFCAF1BC), // Set the background color here
        appBar: AppBar(
          title: Text('Customer Home'),
          backgroundColor: Color(0xFFCAF1BC),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                Text(
                  'Welcome back, $identifier!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800], // Dark brown color for text
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Feeling hungry? Let’s meet your cravings!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown[600], // Lighter brown color for subtext
                  ),
                ),
                SizedBox(height: 20),
                // Explore Message in the middle and bold
                Center(
                  child: Text(
                    'Explore the best dishes around you!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800], // Dark green color for content
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                // Options for the Home Page in the middle with spacing
                GridView.count(
                  shrinkWrap: true, // Allow the GridView to be smaller
                  physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 20, // Spacing between rows
                  crossAxisSpacing: 20, // Spacing between columns
                  children: [
                    _buildOptionCard(
                      title: 'Browse Menu',
                      icon: Icons.menu_book,
                      onTap: () {
                        Navigator.pushNamed(context, '/customerbrowsemenu', arguments: {'identifier': identifier, 'token': token});
                      },
                    ),
                    _buildOptionCard(
                      title: 'Create Customized Food',
                      icon: Icons.create,
                      onTap: () {
                        Navigator.pushNamed(context, '/customercustomizedrequests', arguments: {'identifier': identifier, 'token': token});
                      },
                    ),
                    _buildOptionCard(
                      title: 'Ratings & Reviews',
                      icon: Icons.rate_review,
                      onTap: () {
                        Navigator.pushNamed(context, '/ratingsReviews');
                      },
                    ),
                    _buildOptionCard(
                      title: 'More Options',
                      icon: Icons.more_horiz,
                      onTap: () {
                        // Handle more options
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
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
              icon: Icon(Icons.help),
              label: 'Help',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green[800], // Dark green color for selected item
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      );
    } else {
      // Handle the case where args is not a valid Map
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Invalid arguments passed to Customer Home Page.'),
        ),
      );
    }
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.green[800], // Dark green color for icons
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800], // Dark brown color for text
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
