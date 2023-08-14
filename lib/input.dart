import 'package:flutter/material.dart';
import 'package:fluttter_akreditasi/submenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';


class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  List<dynamic> _inputList = [];
  List<dynamic> _categoryList = [];
  String? _selectedCategory;
  List<dynamic> _originalInputList = []; // Store the original list

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchCategories();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:8081/input/vw-find-all'));
    if (response.statusCode == 200) {
      setState(() {
        _inputList = json.decode(response.body) as List<dynamic>;
        _originalInputList = List.from(_inputList); // Store the original list
      });
    }
  }


  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:8081/elemen/get-all'));
    if (response.statusCode == 200) {
      setState(() {
        _categoryList = json.decode(response.body) as List<dynamic>;
      });
    }
  }

  void _filterInputList() {
    print("Selected Category: $_selectedCategory");

    setState(() {
      if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        _inputList = List.from(_originalInputList); // Reset to original list
      } else {
        print("Category List: $_categoryList");

        _inputList = _originalInputList
            .where((input) => input['namaKategori'] == _selectedCategory)
            .toList();
      }
    });
  }



  Future<void> deleteInput(int inputId) async {
    final response =
    await http.delete(Uri.parse('http://localhost:8081/input/delete/$inputId'));
    if (response.statusCode == 200) {
      // Refresh the data after successful deletion
      fetchData();
    } else {
      // Show an error message or handle the error
      print('Failed to delete input');
    }
  }

  Future<void> confirmDeleteInput(int inputId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4C80F1), Color(0xFF0083C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Konfirmasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Anda yakin ingin menghapus input ini?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Batal'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                        textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        deleteInput(inputId);
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> showEditInputDialog(BuildContext context, int inputId) async {
    Map<String, dynamic> existingData = await fetchExistingData(inputId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditInputDialog(
          inputId: inputId,
          existingData: existingData,
          editInput: editInput,
          // downloadFile: downloadFile,
        );
      },
    );
  }


  Future<Map<String, dynamic>> fetchExistingData(int inputId) async {
    final response =
    await http.get(Uri.parse('http://localhost:8081/input/find-by-id/$inputId'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      print('Gagal mengambil data');
      return {};
    }
  }

  // Function to handle the file download based on the file URL
  Future<void> downloadFile(int inputId) async {
    final url = Uri.parse('http://localhost:8081/input/download-by--input-id/$inputId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fileUrl = data['file'];

        // Use the URL launcher to trigger the download process in the web browser
        await launch(fileUrl);
      } else {
        print('Failed to fetch file URL.');
      }
    } catch (e) {
      print('Error occurred while fetching file URL: $e');
    }
  }


  Future<void> editInput(int inputId, Map<String, dynamic> updatedData, Uint8List? fileBytes, String originalFileName) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://localhost:8081/input/update/$inputId'),
    );

    updatedData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: originalFileName, // Use the original file name
          contentType: MediaType('application', 'octet-stream'),
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      fetchData();
    } else {
      print('Failed to update input');
    }
  }


  Future<void> createInput(Map<String, dynamic> inputData, Uint8List? fileBytes, String originalFileName) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8081/input/create'),
    );

    inputData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: originalFileName, // Use the original file name
          contentType: MediaType('application', 'octet-stream'),
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      fetchData();
    } else {
      print('Failed to create input');
    }
  }


  void _handleMenuItemSelected(String menu) {
    // Implement the logic based on the selected menu
    // For example, you can navigate to different pages or perform specific actions.
    print('Selected menu: $menu');
  }

  void _showActionsDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: IntrinsicWidth( // Tambahkan IntrinsicWidth untuk menyesuaikan lebar otomatis
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'Pilih Aksi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          showEditInputDialog(context,
                              _inputList[index]['inputId']);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue.withOpacity(0.8),
                          padding: EdgeInsets.symmetric(vertical: 12.0,
                              horizontal: 20.0), // Tambahkan padding horizontal
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        icon: Icon(Icons.edit, size: 24),
                        // Tambahkan size pada Icon
                        label: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white,
                              fontFamily: 'Roboto',
                              fontSize: 18), // Customize font size
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          confirmDeleteInput(_inputList[index]['inputId']);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red.withOpacity(0.8),
                          padding: EdgeInsets.symmetric(vertical: 12.0,
                              horizontal: 20.0), // Tambahkan padding horizontal
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        icon: Icon(Icons.delete, size: 24),
                        // Tambahkan size pada Icon
                        label: Text(
                          'Hapus',
                          style: TextStyle(color: Colors.white,
                              fontFamily: 'Roboto',
                              fontSize: 18), // Customize font size
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          downloadFile(_inputList[index]['inputId']);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green.withOpacity(0.8),
                          padding: EdgeInsets.symmetric(vertical: 12.0,
                              horizontal: 20.0), // Tambahkan padding horizontal
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        icon: Icon(Icons.download, size: 24),
                        // Tambahkan size pada Icon
                        label: Text(
                          'Unduh',
                          style: TextStyle(color: Colors.white,
                              fontFamily: 'Roboto',
                              fontSize: 18), // Customize font size
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Input'),
      ),
      drawer: Submenu(
        onMenuItemSelected: _handleMenuItemSelected,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showCreateInputDialog(context);
                      },
                      icon: Icon(Icons.add),
                      label: Text('Buat Input Baru'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        textStyle: TextStyle(fontSize: 16.0),
                        padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: DropdownButton<String?>(
                        value: _selectedCategory,
                        hint: Text('Filter by category'),
                        onChanged: (value) {
                          print("Selected Category Changed: $value");
                          setState(() {
                            _selectedCategory = value;
                            _filterInputList();
                          });
                        },
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Show All :kategori'),
                          ),
                          ..._categoryList.map<DropdownMenuItem<String?>>((category) {
                            return DropdownMenuItem<String?>(
                              value: category['namaKategori'],
                              child: Text(category['namaKategori']),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue as Color),
                    headingTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      fontFamily: 'Futuristic',
                    ),
                    dataRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[800] as Color),
                    dataTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    columns: [
                      DataColumn(
                        label: Text('Input ID'),
                      ),
                      DataColumn(
                        label: Text('Pernyataan'),
                      ),
                      DataColumn(
                        label: Text('File'),
                      ),
                      DataColumn(
                        label: Text('Bobot'),
                      ),
                      DataColumn(
                        label: Text('Nilai'),
                      ),
                      DataColumn(
                        label: Text('Actions'),
                      ),
                    ],
                    rows: _inputList.asMap().entries.map((entry) {
                      int index = entry.key;
                      dynamic input = entry.value;

                      return DataRow(
                        cells: [
                          DataCell(Text('${input['inputId']}')),
                          DataCell(Text('${input['pernyataan']}')),
                          DataCell(Text(input['file'] ?? 'N/A')),
                          DataCell(Text('${input['bobot']}')),
                          DataCell(Text('${input['nilai']}')),
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showActionsDialog(context, index);
                                },
                                icon: Icon(Icons.play_arrow),
                                label: Text(''),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }





  Future<void> showCreateInputDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateInputDialog(
          createInput: createInput,
        );
      },
    );
  }
}

class CreateInputDialog extends StatefulWidget {
  final Function(Map<String, dynamic>, Uint8List, String) createInput;

  CreateInputDialog({required this.createInput});

  @override
  _CreateInputDialogState createState() => _CreateInputDialogState();
}

class _CreateInputDialogState extends State<CreateInputDialog> {
  TextEditingController keteranganController = TextEditingController();
  TextEditingController komponenIdController = TextEditingController();
  String? originalFileName;
  Uint8List? fileBytes;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C80F1), Color(0xFF0083C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Buat Input Baru',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.0),
            TextFormField(
              controller: keteranganController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
              decoration: InputDecoration(
                labelText: 'Keterangan',
                labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.white, // Cursor color will be white
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: komponenIdController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
              decoration: InputDecoration(
                labelText: 'Komponen ID',
                labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.white, // Cursor color will be white
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                uploadInput.click();

                uploadInput.onChange.listen((event) async {
                  final files = uploadInput.files;
                  if (files?.length == 1) {
                    final file = files![0];
                    final reader = html.FileReader();
                    reader.readAsArrayBuffer(file);
                    await reader.onLoadEnd.first;
                    setState(() {
                      fileBytes = Uint8List.fromList(reader.result as List<int>);
                      originalFileName = file.name; // Save the original file name
                    });
                  }
                });
              },
              child: Text('Pilih File'),
              style: ElevatedButton.styleFrom(
                primary: Colors.white12,
                textStyle: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              originalFileName != null ? 'File: $originalFileName' : 'No file selected',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                if (fileBytes != null) {
                  Map<String, dynamic> inputData = {
                    'keterangan': keteranganController.text,
                    'komponen': int.parse(komponenIdController.text),
                  };
                  widget.createInput(inputData, fileBytes!, originalFileName!); // Pass the original file name
                  Navigator.of(context).pop();
                } else {
                  print('Please select a file.');
                }
              },
              child: Text('Simpan'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class EditInputDialog extends StatefulWidget {
  final int inputId;
  final Map<String, dynamic> existingData;
  final Future<void> Function(int, Map<String, dynamic>, Uint8List?, String) editInput;

  EditInputDialog({
    required this.inputId,
    required this.existingData,
    required this.editInput,
  });

  @override
  _EditInputDialogState createState() => _EditInputDialogState();
}

class _EditInputDialogState extends State<EditInputDialog> {
  TextEditingController keteranganController = TextEditingController();
  TextEditingController komponenIdController = TextEditingController();
  String? originalFileName;
  Uint8List? fileBytes;

  @override
  void initState() {
    super.initState();
    keteranganController.text = widget.existingData['keterangan'].toString();
    komponenIdController.text = widget.existingData['komponenId'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C80F1), Color(0xFF0083C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Input',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.0),
            TextFormField(
              controller: keteranganController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
              decoration: InputDecoration(
                labelText: 'Keterangan',
                labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.white, // Cursor color will be white
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: komponenIdController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
              decoration: InputDecoration(
                labelText: 'Komponen ID',
                labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              cursorColor: Colors.white, // Cursor color will be white
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                uploadInput.click();

                uploadInput.onChange.listen((event) async {
                  final files = uploadInput.files;
                  if (files?.length == 1) {
                    final file = files![0];
                    final reader = html.FileReader();
                    reader.readAsArrayBuffer(file);
                    await reader.onLoadEnd.first;
                    setState(() {
                      fileBytes = Uint8List.fromList(reader.result as List<int>);
                      originalFileName = file.name; // Save the original file name
                    });
                  }
                });
              },
              child: Text('Pilih File'),
              style: ElevatedButton.styleFrom(
                primary: Colors.white12,
                textStyle: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              originalFileName != null ? 'File: $originalFileName' : 'No file selected',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> updatedData = {
                  'keterangan': keteranganController.text,
                  'komponen': int.parse(komponenIdController.text),
                  'file': fileBytes != null ? originalFileName : widget.existingData['file'],
                };
                widget.editInput(widget.inputId, updatedData, fileBytes, originalFileName!);
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}