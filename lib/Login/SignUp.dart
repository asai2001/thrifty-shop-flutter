import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'flutter_avatar.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nomorController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  int _selectedRoleId;
  PickedFile _imageFile;
  Uint8List _imageBytes;
  Uint8List resizedBytes;

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://localhost:8081/user/create-byrole');
      final request = http.MultipartRequest('POST', url);

      if (_imageFile != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'profile_image',
          _imageBytes,
          filename: 'profile_image.jpg',
        ));
      }

      request.fields['nama'] = _namaController.text;
      request.fields['nomor'] = _nomorController.text;
      request.fields['alamat'] = _alamatController.text;
      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['roleId'] = _selectedRoleId.toString();

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final responseJson = jsonDecode(responseData);

      if (responseJson['status'] == 'success') {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Berhasil membuat akun. Silakan klik Login untuk melanjutkan.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Login'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(responseJson['message']),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(error.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.0),
                Avatar(
                  radius: 80.0,
                  imageBytes: _imageBytes,
                  onPressed: _getImage,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),

                  controller: _namaController,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,

                  controller: _nomorController,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(),
                  ),

                  controller: _alamatController,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    return null;
                  },
                  controller: _emailController,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                  controller: _passwordController,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi Password tidak boleh kosong';
                    }
                    else if (value != _passwordController.text) {
                      return 'Konfirmasi Password tidak cocok';
                    }
                    return null;
                  },
                  controller: _confirmPasswordController,
                ),
                SizedBox(height: 16.0),

                DropdownButtonFormField<int>(
                  value: _selectedRoleId,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('Customer'),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text('Seller'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleId = value;
                    });
                  },
                  // validator: (value) {
                  //   if (_selectedRoleId == null || _selectedRoleId == 0) {
                  //     return 'Please select a role';
                  //   } else {
                  //     return null;
                  //   }
                  // },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _signUp();
                    }
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



