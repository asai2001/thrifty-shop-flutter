import 'package:flutter/material.dart';

import 'input.dart';
import 'kategori_elemen.dart';
import 'komponen.dart';

class Submenu extends StatefulWidget {
  final Function(String) onMenuItemSelected;

  Submenu({required this.onMenuItemSelected});

  @override
  _SubmenuState createState() => _SubmenuState();
}

class _SubmenuState extends State<Submenu> {
  String selectedItem = '';

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(),
    );
  }

  void _navigateToPage(String title) {
    setState(() {
      selectedItem = title;
    });

    _showLoadingDialog(context);

    // Simulasi delay sebelum berpindah halaman (Anda bisa mengganti ini dengan proses asinkron sesungguhnya)
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context); // Tutup loading dialog
      widget.onMenuItemSelected(title);
      Navigator.pop(context); // Tutup drawer
      if (title == 'Input') {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => InputPage(),
            transitionDuration: Duration.zero,
          ),
        );
      } else if (title == 'Komponen') {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => KomponenPage(),
            transitionDuration: Duration.zero,
          ),
        );
      } else if (title == 'Kategori Elemen') {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => KategoriElemenPage(),
            transitionDuration: Duration.zero,
          ),
        );
      } else if (title == 'Tahun') {
        // Implement navigation to the Tahun page here if needed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[900]!, Colors.black],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 150, // Set the height of the drawer header
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(
                  child: Image.asset(
                    'simftx2.png', // Replace with your image path
                    height: 300,
                    width: 300,
                  ),
                ),
              ),
            ),
            _buildMenuItem('Input', Icons.input),
            _buildMenuItem('Komponen', Icons.extension),
            _buildMenuItem('Kategori Elemen', Icons.category), // Add the "Kategori Elemen" menu item
            _buildMenuItem('Tahun', Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon) {
    bool isSelected = selectedItem == title;
    bool isHovered = false;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _navigateToPage(title);
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[300]!, Colors.blue[100]!],
              )
                  : null,
              border: isSelected
                  ? Border(
                left: BorderSide(
                  color: Colors.white,
                  width: 5,
                ),
              )
                  : null,
            ),
            child: ListTile(
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
              hoverColor: Colors.blue[300],
              selectedTileColor: Colors.blue[300],
              selected: isSelected,
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


