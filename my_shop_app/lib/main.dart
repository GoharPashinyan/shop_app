import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'categories_page.dart';
import 'beacon_scanner.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeNotifications();
  startBeaconScan();

  // Ստուգում ենք՝ արդյոք login արված է
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Shop App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Այստեղ որոշում ենք՝ որ էջը բացվի առաջինը
      initialRoute: isLoggedIn ? '/categories' : '/',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/categories': (context) => CategoriesPage(),
      },
    );
  }
}
