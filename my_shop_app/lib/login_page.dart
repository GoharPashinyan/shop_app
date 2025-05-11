import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'beacon_scanner.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showSnackBar('Խնդրում ենք լրացնել բոլոր դաշտերը');
      setState(() {
        isLoading = false;
      });
      return;
    }

    var url = Uri.parse('http://192.168.1.39:8080/store_api/login.php');

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        debugPrint("Decoded Response: $responseData");

        if (responseData["success"]) {
          int userId = responseData["user_id"];
          String username = responseData["username"];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userId);
          await prefs.setString('username', username);
          await prefs.setBool('isLoggedIn', true);

          login();

          showSnackBar("Հաջող մուտք! Տեղափոխվում է...");

          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacementNamed(context, '/categories');
          });
        } else {
          showSnackBar(responseData["message"]);
        }
      } else {
        showSnackBar("Սերվերի սխալ. Կոդ՝ ${response.statusCode}");
      }
    } catch (e) {
      showSnackBar('Սերվերի խնդիր։ Ստուգիր կապը։');
    }

    setState(() {
      isLoading = false;
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF006400),
        title: Text('Login', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            buildTextField(controller: usernameController, label: "Username"),
            SizedBox(height: 20),
            buildTextField(controller: passwordController, label: "Password", obscureText: true),
            SizedBox(height: 30),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF006400),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: loginUser,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({required TextEditingController controller, required String label, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}