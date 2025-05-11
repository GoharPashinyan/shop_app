import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_page.dart';

class ProductsPage extends StatefulWidget {
  final String category;

  const ProductsPage({Key? key, required this.category}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> products = [];
  List<dynamic> cartItems = [];
  bool isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchProducts();
  }

  Future<void> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('user_id');
    if (id == null) {
      String? stringId = prefs.getString('user_id');
      if (stringId != null) {
        id = int.tryParse(stringId);
      }
    }
    setState(() {
      userId = id;
    });

    print("User ID: $userId");
  }

  Future<void> fetchProducts() async {
    var url = Uri.parse('http://192.168.1.39:8080/store_api/get_products.php?type=${widget.category}');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true && data['products'] != null) {
          setState(() {
            products = List.from(data['products']);
            isLoading = false;
          });
        } else {
          showError("No products found in this category");
        }
      } else {
        showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching products: $e");
    }
  }

  Future<void> addToCart(dynamic product) async {
    if (userId == null) {
      showError("User is not logged in");
      return;
    }

    var url = Uri.parse('http://192.168.1.39:8080/store_api/add_to_cart.php');
    var body = {
      'user_id': userId.toString(),
      'product_id': product['ID'].toString(),
      'discount': product['Discount']?.toString() ?? '0.00',
    };

    print("Sending to server: $body");

    try {
      var response = await http.post(url, body: body);
      var data = jsonDecode(response.body);

      print("Server response: $data");

      if (data['success']) {
        setState(() {
          cartItems.add(product);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        showError(data['message']);
      }
    } catch (e) {
      print("Error details: $e");
      showError("Error adding product to cart: $e");
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void goToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: Text('${widget.category} Products', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: goToCartPage,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logoutUser,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(child: Text("No products available in this category"))
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return buildProductItem(context, products[index]);
                  },
                ),
    );
  }

  Widget buildProductItem(BuildContext context, dynamic product) {
    print("Building product: ${product.toString()}");

    String productName = product['Name'] ?? 'No Name';
    String productPrice = product['Price'] != null ? '\$${product['Price']}' : 'N/A';

    List<String> imageUrls = [];
    if (product.containsKey('image') && product['image'] != null) {
      if (product['image'] is List) {
        imageUrls = List<String>.from(product['image']);
      } else if (product['image'] is String) {
        imageUrls = [product['image']];
      }
    }
    imageUrls = imageUrls.map((url) => url.replaceAll(RegExp(r'\?.*$'), '')).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(productName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          subtitle: Text(productPrice),
          leading: imageUrls.isNotEmpty && Uri.tryParse(imageUrls[0])?.hasAbsolutePath == true
              ? Image.network(
                  imageUrls[0],
                  width: 80, height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/placeholder.jpg', width: 80, height: 80);
                  },
                )
              : Image.asset('assets/images/placeholder.jpg', width: 80, height: 80),
          trailing: ElevatedButton(
            onPressed: () {
              print("Adding to cart: ${product['ID']}");
              addToCart(product);
            },
            child: Text("Add to Cart"),
          ),
        ),
      ),
    );
  }
}
