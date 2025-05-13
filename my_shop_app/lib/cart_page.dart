import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    debugPrint("🔹 Saved user_id from SharedPreferences: $userId");

    if (userId == null) {
      debugPrint("❌ User ID is null, cannot fetch cart");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.39:8080/store_api/get_cart.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            cartItems = responseData['cart_items'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          debugPrint("❌ Error fetching cart items: ${responseData['message']}");
        }
      } else {
        debugPrint("❌ Failed to load cart items");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading cart: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 102, 58, 1),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "SHOPPING CART",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(child: Text("Your cart is empty"))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var product = cartItems[index];

                    List<String> imageUrls = [];
                    try {
                      imageUrls = List<String>.from(jsonDecode(product['image']));
                    } catch (e) {
                      debugPrint("❌ Error decoding image URLs: $e");
                    }

                    String imageUrl = imageUrls.isNotEmpty
                        ? imageUrls[0]
                        : 'assets/images/placeholder.jpg';

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: imageUrl.startsWith('http')
                            ? Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                      'assets/images/placeholder.jpg',
                                      width: 50,
                                      height: 50);
                                },
                              )
                            : Image.asset(imageUrl, width: 50, height: 50),
                        title: Text(product['Name'] ?? 'No Name'),
                        subtitle: Text(
                          'Price: \$${product['Price'] ?? '0.00'}\nDiscount: \$${product['discount'] ?? '0.00'}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
