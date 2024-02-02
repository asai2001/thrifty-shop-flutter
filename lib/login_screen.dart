import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'input.dart';

class LoginField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const LoginField({
    Key? key,
    required this.hintText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450, // Lebar sesuaikan dengan kebutuhan
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: TextStyle(color: Colors.black, fontSize: 16), // Ukuran teks sesuaikan dengan kebutuhan
        textAlign: TextAlign.center, // Text di tengah
        obscureText: hintText.toLowerCase() == 'password',
        onChanged: (value) {
          // Tambahkan logika pemanggilan fungsi login di sini jika diperlukan
        },
      ),
    );
  }
}





class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final String apiUrl = "http://localhost:8089/api/login-prodi/$username/$password";
      final response = await http.get(Uri.parse(apiUrl));

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['status'] == 'success') {
        // Simpan data login ke shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        prefs.setString('password', password);
        prefs.setString('prodiId', responseBody['prodiId']); // Menyimpan prodiId

        return {
          'status': 'success',
          'data': {
            'username': responseBody['username'],
            'password': responseBody['password'],
          },
        };
      } else {
        return {
          'status': 'error',
          'message': 'Error occurred while trying to login',
        };
      }
    } catch (e) {
      print('Error: $e');
      return {
        'status': 'error',
        'message': 'Error occurred while trying to login',
      };
    }
  }

  Future<String?> _getSavedProdiId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('prodiId');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('vb.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'simftx2.png',
                width: 500,
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 15),
              LoginField(
                hintText: 'username',
                controller: usernameController,
              ),
              const SizedBox(height: 15),
              LoginField(
                hintText: 'password',
                controller: passwordController,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Mengambil nilai dari controller
                  String username = usernameController.text;
                  String password = passwordController.text;

                  // Memanggil fungsi login dengan menggunakan nilai dari controller
                  Map<String, dynamic> loginResponse = await login(username, password);

                  print('Status: ${loginResponse['status']}');
                  print('Message: ${loginResponse['message']}');

                  if (loginResponse['status'] == 'success') {
                    // Lakukan navigasi ke halaman selanjutnya atau lakukan tindakan tertentu setelah login berhasil

                    // Simpan informasi login ke shared preferences
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool('isLoggedIn', true);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => InputPage()),
                    );
                  } else {
                    // Tampilkan pesan kesalahan atau lakukan tindakan jika login gagal
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error', style: TextStyle(color: Colors.red)),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loginResponse['message'],
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 20),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Tutup dialog
                                  },
                                  child: Text('OK'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue, // Warna latar belakang tombol
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Bentuk border tombol
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.black,
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Warna latar belakang tombol
                  padding: EdgeInsets.symmetric(horizontal: 190, vertical: 15), // Padding tombol
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Bentuk border tombol
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18, // Ukuran teks tombol
                    fontWeight: FontWeight.bold, // Ketebalan teks tombol
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
