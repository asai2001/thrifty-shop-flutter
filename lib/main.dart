import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttter_akreditasi/input.dart';
import 'package:fluttter_akreditasi/kategori_elemen.dart';
import 'package:fluttter_akreditasi/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'komponen.dart';


void main() {
  runApp(const MyApp());
}

Future<void> _checkLogin(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (!isLoggedIn) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akreditasi',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/komponen': (context) {
          _checkLogin(context);
          return const KomponenPage();
        },
        '/input': (context) {
          _checkLogin(context);
          return const InputPage();
        },
        '/elemen': (context) {
          _checkLogin(context);
          return const KategoriElemenPage();
        },
      },
    );
  }
}