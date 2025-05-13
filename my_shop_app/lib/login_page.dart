import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final Color mainGreen = Color.fromRGBO(0, 102, 58, 1);

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

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData["success"]) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', responseData["user_id"]);
          await prefs.setString('username', responseData["username"]);
          await prefs.setBool('isLoggedIn', true);

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: mainGreen,
            height: 80,
            padding: EdgeInsets.only(left: 10, right: 20),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 10),
                Text(
                  "LOGIN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Hello,\nWelcome back!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/images/login_illustration.png',
                    height: 250,
                  ),
                  SizedBox(height: 30),
                  buildInputField(
                    controller: usernameController,
                    hintText: "User Name",
                  ),
                  SizedBox(height: 20),
                  buildInputField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
