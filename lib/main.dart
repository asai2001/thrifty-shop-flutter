import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thrifty_test/HomeScreen.dart';
import 'package:thrifty_test/dashboard.dart';

import 'Login.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Flutter E-Commerce',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => TrifhtyShopDashboard(),
      },
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    // home: LoginPage(),
  );
}
}


