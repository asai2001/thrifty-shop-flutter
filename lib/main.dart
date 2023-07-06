import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thrifty_test/HomeScreen.dart';
import 'package:thrifty_test/dashboard.dart';
import 'Login/Login.dart';
import 'ProfilePage.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Flutter E-Commerce',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => TrifhtyShopDashboard(),
        '/profile': (context) => ProfilePage(),
      },
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    // home: LoginPage(),
  );
}
}


