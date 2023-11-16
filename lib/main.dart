import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttter_akreditasi/Theme_Provider.dart';
import 'package:fluttter_akreditasi/input.dart';
import 'package:fluttter_akreditasi/kategori_elemen.dart';
import 'package:provider/provider.dart';


import 'komponen.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akreditasi',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/input',
      routes: {
        '/komponen': (context) => const KomponenPage(),
        '/input': (context) => const InputPage(),
        '/elemen': (context) => const KategoriElemenPage(),
      },
    );
  }
}