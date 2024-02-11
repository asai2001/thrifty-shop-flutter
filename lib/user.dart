import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:fluttter_akreditasi/submenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserControlPage extends StatefulWidget {
  @override
  _UserControlPageState createState() => _UserControlPageState();
}

class _UserControlPageState extends State<UserControlPage> {
  late List<Map<String, dynamic>> _prodiList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse("http://localhost:8089/prodi/find-all"));
    if (response.statusCode == 200) {
      final List<dynamic> decodedJson = jsonDecode(response.body);
      setState(() {
        _prodiList = decodedJson.cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Check login status before loading the page
  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      // Jika tidak login, arahkan ke halaman login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }


  Future<void> createProdi(Map<String, dynamic> prodiData) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8089/prodi/create'),
    );


    // Add the prodiData as multipart/form-data
    prodiData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      fetchData();
    } else {
      // Error creating prodi
      // You can handle the error or display a message to the user
    }
  }


  void _handleMenuItemSelected(String menu) {
    // Implement the logic based on the selected menu
    // For example, you can navigate to different pages or perform specific actions.
    print('Selected menu: $menu');
  }

  Future<void> showCreateProdiDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateProdiDialog(
          createProdi: createProdi,
          prodiList: _prodiList,
        );
      },
    );
  }




  Future<void> deleteprodi(String prodiId) async {
    final response = await http.delete(
        Uri.parse('http://localhost:8089/prodi/delete/$prodiId'));
    if (response.statusCode == 200) {
      // Refresh the data after successful deletion
      fetchData();
    } else {
      // Show an error message or handle the error
      print('Failed to delete kategori elemen');
    }
  }

  Future<void> confirmDeleteprodi(String prodiId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Konfirmasi',
            style: TextStyle(
              color: Colors.indigo,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Anda yakin ingin menghapus user ini?',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    elevation: 0,
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    deleteprodi(prodiId);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    elevation: 0,
                  ),
                  child: Text(
                    'Hapus',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
      ),
      drawer: Submenu(
        onMenuItemSelected: _handleMenuItemSelected,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showCreateProdiDialog(context);
              },
              icon: const Icon(
                Icons.add,
                color: Colors.indigo,
              ),
              label: const Text(
                'Buat User Baru',
                style: TextStyle(
                  color: Colors.indigo,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Ubah warna tombol
                textStyle: const TextStyle(fontSize: 16.0),
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _prodiList.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> prodi = _prodiList[index];
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        '${prodi['nama']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NIK: ${prodi['nik']}'),
                          Text('Username: ${prodi['username']}'),
                          Text('Password: ${prodi['password']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showEditProdiDialog(context, prodi['prodiId']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              confirmDeleteprodi(prodi['prodiId']);
                            },
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



  List<DataColumn2> generateDataColumns(List<Map<String, dynamic>> prodiList) {
    List<DataColumn2> columns = [
      DataColumn2(
        label: Text(
          'NO',
        ),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text(
          'nik',
        ),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text(
          'nama',
        ),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text(
          'username',
        ),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text(
          'password',
        ),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text(
          'Actions',
        ),
      ),
    ];
    return columns;
  }


  Future<Map<String, dynamic>> fetchExistingData(String prodiId) async {
    final response = await http.get(
        Uri.parse('http://localhost:8089/prodi/find-by-id/$prodiId'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Show an error message or handle the error
      print('Failed to fetch existing data');
      return {};
    }
  }

  Future<void> editprodi(String prodiId,
      Map<String, dynamic> updatedData) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://localhost:8089/prodi/update/$prodiId'),
      );

      // Add input data to request fields
      updatedData.forEach((key, value) {
        request.fields[key] = value.toString();
      });


      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Refresh the data after successful update
        fetchData();
      } else {
        // Show an error message or handle the error
        print('Failed to update kategori elemen');
      }
    } catch (e) {
      // Handle errors
      print('Error: $e');
    }
  }


  void showEditProdiDialog(BuildContext context, String prodiId) async {
    Map<String, dynamic> existingData = await fetchExistingData(prodiId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          prodiId: prodiId,
          existingData: existingData,
          editProdi: editprodi, // Perubahan nama fungsi sesuai dengan CustomDialog
        );
      },
    );
  }
}

class CustomDialog extends StatefulWidget {
  final String prodiId;
  final Map<String, dynamic> existingData;
  final Function(String, Map<String, dynamic>) editProdi;

  const CustomDialog({
    Key? key,
    required this.prodiId,
    required this.existingData,
    required this.editProdi,
  }) : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.existingData['nama'].toString(),
    );
    _nikController = TextEditingController(
      text: widget.existingData['nik'].toString(),
    );
    _usernameController = TextEditingController(
      text: widget.existingData['username'].toString(),
    );
    _passwordController = TextEditingController(
      text: widget.existingData['password'].toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Edit User',
        style: TextStyle(
          color: Colors.indigo,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _namaController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Nama',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.indigo,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _nikController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'NIK',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.indigo,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _usernameController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.indigo,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _passwordController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.indigo,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Map<String, dynamic> updatedData = {
              'nama': _namaController.text,
              'nik': _nikController.text,
              'username': _usernameController.text,
              'password': _passwordController.text,
            };
            widget.editProdi(widget.prodiId, updatedData);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.indigo,
            elevation: 0,
          ),
          child: Text(
            'Simpan',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}







class CreateProdiDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) createProdi;
  final List<Map<String, dynamic>> prodiList;

  const CreateProdiDialog({
    Key? key,
    required this.createProdi,
    required this.prodiList,
  }) : super(key: key);

  @override
  _CreateProdiDialogState createState() => _CreateProdiDialogState();
}

class _CreateProdiDialogState extends State<CreateProdiDialog> {
  late TextEditingController namaController;
  late TextEditingController nikController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController();
    nikController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Buat User Baru',
        style: TextStyle(
          color: Colors.indigo,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: namaController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Nama',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.indigo,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: nikController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'NIK',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.indigo,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: usernameController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.indigo,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: passwordController,
              style: TextStyle(color: Colors.black),
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.indigo,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String nama = namaController.text;
            String nik = nikController.text;
            String username = usernameController.text;
            String password = passwordController.text;

            if (username.isNotEmpty && password.isNotEmpty) {
              Map<String, dynamic> prodiData = {
                'nama': nama,
                'nik': nik,
                'username': username,
                'password': password,
              };
              widget.createProdi(prodiData);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Username dan Password tidak boleh kosong',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.indigo,
            elevation: 0,
          ),
          child: Text(
            'Simpan',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
