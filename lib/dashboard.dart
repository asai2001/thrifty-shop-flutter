import 'package:flutter/material.dart';
import 'package:thrifty_test/Cart/Cart.dart';
import 'package:thrifty_test/HomeScreen.dart';
import 'package:thrifty_test/Login/Login.dart';
import 'package:thrifty_test/ProfilePage.dart';
import 'package:thrifty_test/Wishlist/Wishlist.dart';

class TrifhtyShopDashboard extends StatefulWidget {
  final String accessToken;
  final int id;

  TrifhtyShopDashboard({this.accessToken, this.id});

  @override
  _TrifhtyShopDashboardState createState() => _TrifhtyShopDashboardState();
}

class _TrifhtyShopDashboardState extends State<TrifhtyShopDashboard> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    Wishlist(),
    Cart(),
    NotificationPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trifhty Shop'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) {
              return {'Pengaturan Akun', 'Keluar'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // tambahkan properti type
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage Account',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleMenuSelection(String choice) {
    if (choice == 'Pengaturan Akun') {
      // Add code for navigating to account settings page
    } else if (choice == 'Keluar') {
      // Add code for logging out
    }
  }
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Account Page'),
    );
  }
}

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Notification Page'),
    );
  }
}

