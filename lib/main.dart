import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttter_akreditasi/input.dart';
import 'package:fluttter_akreditasi/kategori_elemen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'komponen.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akreditasi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/input',
      routes: {
        '/komponen': (context) => KomponenPage(),
        '/input': (context) => InputPage(),
        '/elemen': (context) => KategoriElemenPage(),
      },
    );
  }
}
