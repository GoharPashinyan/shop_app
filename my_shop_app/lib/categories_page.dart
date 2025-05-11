import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'products_page.dart';
import 'cart_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<String> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    var url = Uri.parse('http://192.168.1.39:8080/store_api/get_categories.php');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data.containsKey('type') && data['type'] != null) {
          setState(() {
            categories = List<String>.from(data['type']);
            isLoading = false;
          });
        } else {
          showError("Invalid response format");
        }
      } else {
        showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching categories: $e");
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
    );
  }

  Future<void> logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[800],
          automaticallyImplyLeading: false,
          title: Text('Categories', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              tooltip: 'Cart',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () => logoutUser(context),
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : categories.isEmpty
                ? Center(child: Text("No categories found", style: TextStyle(fontSize: 18)))
                : GridView.builder(
                    padding: EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return buildCategoryItem(context, categories[index]);
                    },
                  ),
      ),
    );
  }

  Widget buildCategoryItem(BuildContext context, String categoryName) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsPage(category: categoryName),
            ),
          );
        },
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          image: DecorationImage(
            image: AssetImage('assets/images/${categoryName.toLowerCase().replaceAll(' ', '_')}.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        categoryName,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  ],
),

      ),
    );
  }
}
