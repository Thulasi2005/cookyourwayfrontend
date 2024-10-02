import 'package:flutter/material.dart';

class FoodMakerHomePage extends StatefulWidget {
  final String identifier;
  final String token;

  const FoodMakerHomePage({Key? key, required this.identifier, required this.token}) : super(key: key);

  @override
  _FoodMakerHomePageState createState() => _FoodMakerHomePageState();
}

class _FoodMakerHomePageState extends State<FoodMakerHomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward().then((value) {
      _controller.reverse();
    });

    // Navigate to the corresponding page
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/foodmakerhomepage'); // Home page
        break;
      case 1:
        Navigator.pushNamed(context, '/foodmakerprofile', arguments: {
        'identifier': widget.identifier,
        'token': widget.token,
        } ); // Orders page); // Profile page
        break;
      case 2:
        Navigator.pushNamed(context, '/foodmakerpaymentreceival', arguments: {
          'identifier': widget.identifier,
          'token': widget.token,
        } ); // Orders page
        break;
      case 3:
        Navigator.pushNamed(context, '/tracking'); // Tracking page
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCAF1BC),
      appBar: AppBar(
        title: Text('Food Maker Home'),
        backgroundColor: Colors.green[700],
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome back, Chef ${widget.identifier}!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[900]),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Ready to Cook?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.green[800]),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionButton(
                    icon: Icons.menu,
                    label: 'Menu',
                    onTap: () => Navigator.pushNamed(context, '/foodmakermenu', arguments: {
                      'identifier': widget.identifier,
                      'token': widget.token,
                    }),
                  ),
                  SizedBox(height: 20),
                  _buildOptionButton(
                    icon: Icons.star,
                    label: 'Customized Requests',
                    onTap: () => Navigator.pushNamed(context, '/foodmakerresponsetocustomized', arguments: {
                    'identifier': widget.identifier,
                    'token': widget.token, // Pass the identifier and token here
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracking',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildOptionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.green[800],
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(width: 10),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
