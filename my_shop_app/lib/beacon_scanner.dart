import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'notification_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

bool isLoggedIn = false;
StreamSubscription<List<ScanResult>>? scanSubscription;

void startBeaconScan() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (!isLoggedIn) {
    print("⚠️ Օգտատերը մուտք չի գործել․ Beacon սկան չի արվում");
    return;
  }

  if (FlutterBluePlus.isScanningNow) {
    print("⏱️ Սկանավորումը արդեն ակտիվ է, նոր սկան չի սկսվում");
    return;
  }

  print("✅ Սկսում ենք BLE սկանավորումը...");

  await scanSubscription?.cancel();
  await FlutterBluePlus.startScan(timeout: const Duration(seconds: 1));
  print("🔍 Սկանավորումը ակտիվ է։");

  scanSubscription = FlutterBluePlus.scanResults.listen((results) {
    print("📶 Ստացվեց ${results.length} BLE արդյունք։");

    bool beaconFound = false;
    for (ScanResult r in results) {
      var data = r.advertisementData.manufacturerData;
      final name = r.device.name.isNotEmpty ? r.device.name : "Unnamed";
      print("📡 Սարք՝ $name (${r.device.id})");

      if (data.isEmpty) {
        print("⚠️ manufacturerData դատարկ է");
        continue;
      }

      for (var entry in data.entries) {
        final bytes = entry.value;
        final hexString = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

        print("📦 Manufacturer Data (hex): $hexString");

        if (hexString == "d1 a9 53 39 5d bf 47 82 95 ef 12 5b 0b 9b a5 fa c5") {
          print("🚨 Հայտնաբերվեց Beacon՝ ըստ manufacturerData");
          beaconFound = true;
          fetchProductsAndNotify();
        }
      }
    }

    if (!beaconFound) {
      print("⚠️ Beacon չհայտնաբերվեց։");
    }

    Future.delayed(Duration(minutes: 1), startBeaconScan);
  });
}


void fetchProductsAndNotify() async {
  print("🌐 Ուղարկում ենք հարցում backend-ին...");

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');

  if (userId == null) {
    print("❗️ Օգտատիրոջ ID չկա, հնարավոր է մուտք չի գործել։");
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.39:8080/store_api/check_discounts.php?user_id=$userId'),
    );

    print("🔁 Backend պատասխանի կոդը՝ ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> products = data['products'];

      print("✅ Ստացվեց ${products.length} ապրանք:");

      for (var product in products) {
        final title = product['name'];
        final discount = product['Discount'];
        print("📣 Ուղարկում ենք նոթիֆիկացիա՝ $title - Զեղչ՝ $discount%");
        sendNotification(title, discount);
      }
    } else {
      print("❌ Սխալ HTTP կոդ՝ ${response.statusCode}");
    }
  } catch (e) {
    print("❗️ Սխալ՝ $e");
  }
}

void login() {
  isLoggedIn = true;
  print("🔓 Օգտատիրքը մուտք գործեց։ Սկսում ենք սկանավորումը...");
  startBeaconScan();
}

void logout() {
  isLoggedIn = false;
  print("🔒 Օգտատիրքը դուրս եկավ։ Դադարեցնում ենք սկանավորումը...");
  FlutterBluePlus.stopScan();
  scanSubscription?.cancel();
}