import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final greenColor = Color.fromRGBO(0, 102, 58, 1);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/image1.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),

                  SizedBox(width: 16),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 34, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: greenColor, width: 2),
                      ),
                    ),
                    child: Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
