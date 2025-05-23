import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'categories_page.dart';
import 'beacon_scanner.dart';
import 'notification_service.dart';

import 'package:flutter/services.dart';

class NativeBridge {
  static const platform = MethodChannel('com.example.my_shop_app/foreground');

  static Future<void> startService() async {
    try {
      await platform.invokeMethod('startService');
    } catch (e) {
      print("❌ Սխալ՝ $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeNotifications();
  startBeaconScan();

  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  
  NativeBridge.startService();

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
