import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<dynamic> _cartItems = [];

  Future<List<dynamic>> _getCart() async {
    final response = await http.get(Uri.parse('http://localhost:8081/cart/find-all'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _cartItems = jsonData;
      });
    }
    return _cartItems;
  }

  Future<void> _confirmDeleteCartItem(BuildContext context, int cartId) async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menghapus item ini dari cart?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      await _deleteCartItem(cartId);
      await _getCart();
    }
  }

  Future<void> _deleteCartItem(int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8081/cart/delete/$cartId'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _cartItems = jsonData;
        });
        await _getCart();
      } else {
        throw Exception('Gagal menghapus item dari cart.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }



  @override
  void initState() {
    super.initState();
    _getCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Cart',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _cartItems.length,
        itemBuilder: (BuildContext context, int index) {
          final cartItem = _cartItems[index];
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.network(
                    cartItem['product']['imageUrl'],
                    height: 80,
                    width: 80,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem['product']['title'],
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$${cartItem['product']['price']}',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      _confirmDeleteCartItem(context, cartItem['cartId']);
                      _getCart();
                    },
                    child: Text(
                      'REMOVE',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
