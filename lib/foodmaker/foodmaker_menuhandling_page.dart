import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuItem {
  String id;
  String name;
  double price;
  String description;

  MenuItem({required this.id, required this.name, required this.price, required this.description});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
    };
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'].toString(),
      name: json['name'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      description: json['description'],
    );
  }
}

class MenuPage extends StatefulWidget {
  final String identifier;
  final String token;

  const MenuPage({Key? key, required this.identifier, required this.token}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<MenuItem> menuItems = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.26:8000/api/menu/${widget.identifier}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        menuItems = data.map((item) => MenuItem.fromJson(item)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load menu items: ${response.body}')),
      );
    }
  }

  Future<void> _addMenuItem() async {
    if (_nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {

      final newItem = {
        'identifier': widget.identifier,
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text,
      };

      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/menu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode(newItem),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        setState(() {
          menuItems.add(MenuItem.fromJson(responseData));
          _nameController.clear();
          _priceController.clear();
          _descriptionController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menu item added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add menu item: ${response.body}')),
        );
      }
    }
  }

  Future<void> _editMenuItem(int index) async {
    if (_nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {

      final updatedItem = {
        'identifier': widget.identifier,
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text,
      };

      final response = await http.put(
        Uri.parse('http://192.168.1.26:8000/api/menu/${menuItems[index].id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode(updatedItem),
      );

      if (response.statusCode == 200) {
        setState(() {
          menuItems[index] = MenuItem.fromJson(json.decode(response.body));
          _nameController.clear();
          _priceController.clear();
          _descriptionController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menu item updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update menu item: ${response.body}')),
        );
      }
    }
  }

  Future<void> _deleteMenuItem(int index) async {
    final itemId = menuItems[index].id;
    print('Attempting to delete item with ID: $itemId');

    final response = await http.delete(
      Uri.parse('http://192.168.1.26:8000/api/menu/$itemId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        menuItems.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu item deleted successfully')),
      );
    } else {
      print('Delete request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete menu item: ${response.body}')),
      );
    }
  }

  void _showEditDialog(int index) {
    MenuItem item = menuItems[index];
    _nameController.text = item.name;
    _priceController.text = item.price.toString();
    _descriptionController.text = item.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Menu Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _editMenuItem(index);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Menu'),
        backgroundColor: Color(0xFF4CAF50), // A contrasting color for the AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMenu,
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFCAF1BC), // Set the background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Menu Item',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addMenuItem,
              child: Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50), // A contrasting color for the button
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Menu Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(menuItems[index].name),
                      subtitle: Text('Price: \$${menuItems[index].price} - ${menuItems[index].description}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditDialog(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteMenuItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
