import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrifty_test/Login/Login.dart';

class ProfilePage extends StatefulWidget {
  final String accessToken;
  final int id;

  ProfilePage({this.accessToken, this.id});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>> _futureProfileData;

  @override
  void initState() {
    super.initState();
    _futureProfileData = _fetchProfileData();
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? widget.accessToken;
    final id = prefs.getInt('id') ?? widget.id;

    final response = await http.get(
      Uri.parse('http://localhost:8081/user/get-by-id/$id'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _uploadProfileImage() async {
    final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? widget.accessToken;
    final id = prefs.getInt('id') ?? widget.id;

    final response = await http.put(
      Uri.parse('http://localhost:8081/user/update-profile-image/$id'),
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'profileImage': base64Encode(await pickedFile.readAsBytes())},
    );

    if (response.statusCode == 200) {
      setState(() {
        _futureProfileData = _fetchProfileData();
      });
    } else {
      throw Exception('Failed to upload profile image');
    }
  }

  @override
  Widget build(BuildContext context) {
    const double kFontSizeTitle = 28;
    const double kFontSizeContent = 22;
    const FontWeight kFontWeightBold = FontWeight.bold;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Container(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureProfileData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data;
              final profileImageBytes = base64.decode(data['profileImage']);

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  Expanded(
                    child: GestureDetector(
                      onTap: _uploadProfileImage,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(profileImageBytes),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  // Information
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Name
                            _buildProfileDataItem(
                              title: 'Nama',
                              content: data['nama'],
                            ),
                            // Email
                            _buildProfileDataItem(
                              title: 'Email',
                              content: data['email'],
                            ),
                            // Password
                            _buildProfileDataItem(
                              title: 'Password',
                              content: '********',
                            ),
                            // Phone Number
                            _buildProfileDataItem(
                              title: 'Nomor Telepon',
                              content: data['nomor'],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return AlertDialog(
                title: Text("Sesi login telah habis"),
                content: Text("Silahkan klik OK untuk login ulang"),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue, // set the background color
                    ),
                    child: Text("OK", style: TextStyle(color: Colors.white)),
                    // set the text color
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

    Widget _buildProfileDataItem({
    String title,
    String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}


    class ProfileImageUploadDialog extends StatelessWidget {
  const ProfileImageUploadDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Upload Profile Image'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Would you like to upload a new profile image?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Yes'),
          onPressed: () {
// TODO: Implement profile image upload logic
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}










