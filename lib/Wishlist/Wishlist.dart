import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Wishlist extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<Wishlist> {
  List<dynamic> _wishlist = [];

  Future<List<dynamic>> _getWishlist() async {
    final response = await http.get(
        Uri.parse('http://localhost:8081/wishlist/find-all'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _wishlist = jsonData;
      });
    }
    return _wishlist;
  }

  Future<void> _deleteWishlistItem(int wishlistId) async {
    if (wishlistId == null) {
      throw Exception('wishlistId cannot be null');
    }
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8081/wishlist/delete/$wishlistId'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _wishlist = jsonData;
        });
        await _getWishlist();
      } else {
        throw Exception('Gagal menghapus item wishlist.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _getWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WishlistPage',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.0),
            Text(
              'Daftar Barang Favorit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: _wishlist.length,
                itemBuilder: (BuildContext context, int index) {
                  final wishlistItem = _wishlist[index];
                  return Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Card(
                      elevation: 4.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 120.0,
                            width: 120.0,
                            child: Image.network(
                              wishlistItem['product']['imageUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wishlistItem['product']['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    '\$${wishlistItem['product']['price']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        onPressed: () {
                                          // Add edit functionality here
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          'Hapus',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        onPressed: () async {
                                          bool delete = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Hapus item wishlist?'),
                                                content: Text(
                                                    'Apakah Anda yakin ingin menghapus item wishlist ini?'),
                                                actions: [
                                                  TextButton(
                                                    child: Text('Batal'),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, false);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Hapus'),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (delete == true) {
                                            await _deleteWishlistItem(
                                                wishlistItem['wishlistId']);
                                            await _getWishlist();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}