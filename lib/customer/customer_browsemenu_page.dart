import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'customer_itemdetails_page.dart';

class BrowseMenuPage extends StatefulWidget {
  @override
  _BrowseMenuPageState createState() => _BrowseMenuPageState();
}

class _BrowseMenuPageState extends State<BrowseMenuPage> {
  Map<String, List<Map<String, dynamic>>> groupedMenuItems = {}; // Grouped menu items by owner
  bool isLoading = true; // Tracks if data is being loaded
  bool hasError = false; // Tracks if there's an error while loading
  String? identifier;
  String? token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments passed via ModalRoute
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      identifier = args['identifier'] ?? 'Unknown';
      token = args['token'] ?? 'No token';
    }

    fetchMenuItems(); // Fetch menu items after receiving the token and identifier
  }

  // Fetch menu items from the backend
  Future<void> fetchMenuItems() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.26:8000/api/menu'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Print the API response for debugging purposes
        print('API Response: $data');

        // Clear existing items
        groupedMenuItems.clear();

        // Extract items for all owners and group them by owner identifier
        if (data.isNotEmpty) {
          data.forEach((owner, items) {
            groupedMenuItems[owner] = List<Map<String, dynamic>>.from(items);
          });
        }

        // Update the state
        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load menu items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu items: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Menu'),
        backgroundColor: Colors.green[800],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load menu items.',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchMenuItems,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: groupedMenuItems.keys.length,
        itemBuilder: (context, index) {
          final owner = groupedMenuItems.keys.elementAt(index);
          final items = groupedMenuItems[owner]!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the owner identifier as a header
                Text(
                  owner,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // List of menu items for the current owner
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, itemIndex) {
                    final item = items[itemIndex];
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text(item['description']),
                      trailing: Text('\$${item['price']}'),
                      onTap: () => navigateToItemDetails(item['id']),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to shopping cart
          Navigator.pushNamed(context, '/customercart', arguments: {
            'identifier': identifier,
            'token': token,
          },);
        },
        child: Icon(Icons.shopping_cart),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  // Navigate to item details page
  void navigateToItemDetails(int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsPage(
          itemId: itemId,
          token: token!,
          identifier: identifier!, // Pass the identifier here
        ),
      ),
    );
  }
}
