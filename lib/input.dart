import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttter_akreditasi/submenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

import 'package:url_launcher/url_launcher.dart';


class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  List<dynamic> _inputList = [];
  List<dynamic> _categoryList = [];
  String? _selectedCategory;
  List<dynamic> _originalInputList = []; // Store the original list
  String? _selectedYear;
  List<dynamic> _yearList = [];
  final Map<int, List<String>> _fileUrls = {};
  bool _fileUrlsLoaded = false; // Track if file URLs are loaded
  List<Map<String, dynamic>> komponenOptions = [];
  int selectedKomponen = 0;


  @override
  void initState() {
    super.initState();
    fetchData();
    fetchCategories();
    fetchYears();
    fetchKomponenOptions().then((options) {
      if(options.isNotEmpty) {
        setState(() {
          komponenOptions = options;
          selectedKomponen = komponenOptions[0]['komponenId'];
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchKomponenOptions() async {
    final response = await http.get(Uri.parse('http://localhost:8082/komponen/vw-find-all'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load komponen options');
    }
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:8082/input/vw-find-all'));
    if (response.statusCode == 200) {
      setState(() {
        _inputList = json.decode(response.body) as List<dynamic>;
        _originalInputList = List.from(_inputList); // Store the original list
      });

      // Call _loadFileUrls here
      await _loadFileUrls();
    }
  }

  Future<List<String>> fetchFileUrls(int inputId) async {
    final response = await http.get(Uri.parse('http://localhost:8082/input/find-files-by-input/$inputId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> files = data['files'];
      return files.cast<String>();
    } else {
      throw Exception('Failed to load file URLs');
    }
  }

  Future<void> _loadFileUrls() async {
    for (var input in _inputList) {
      final inputId = input['inputId'];
      final response =
      await http.get(Uri.parse('http://localhost:8082/input/find-files-by-input/$inputId'));

      if (response.statusCode == 200) {
        final filesResponse = json.decode(response.body);

        if (filesResponse.containsKey('files')) {
          final fileUrls = filesResponse['files'].cast<String>();
          _fileUrls[inputId] = fileUrls; // Store file URLs by input ID
          print('Input ID: $inputId, File URLs: $fileUrls'); // Add this debug print
        }
      }
    }

    // Set _fileUrlsLoaded to true after loading file URLs
    _fileUrlsLoaded = true;

    // After loading file URLs, trigger a UI update
    setState(() {});
  }



  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:8082/elemen/get-all'));
    if (response.statusCode == 200) {
      setState(() {
        _categoryList = json.decode(response.body) as List<dynamic>;
      });
    }
  }

  Future<void> fetchYears() async {
    final response = await http.get(Uri.parse('http://localhost:8082/tahun/find-all'));
    if (response.statusCode == 200) {
      setState(() {
        _yearList = json.decode(response.body) as List<dynamic>;
      });
    }
  }

  void _filterInputList() {
    setState(() {
      if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        _inputList = List.from(_originalInputList);
      } else {
        _inputList = _originalInputList
            .where((input) => input['namaKategori'] == _selectedCategory)
            .toList();
      }
    });
  }

  void _filterInputList2() {
    setState(() {
      if (_selectedYear == null || _selectedYear!.isEmpty) {
        _inputList = List.from(_originalInputList);
      }else{
        _inputList = _originalInputList
            .where((input) => input['tahun'] == _selectedYear)
            .toList();
      }
    });
  }


  Future<void> deleteInput(int inputId) async {
    final response =
    await http.delete(Uri.parse('http://localhost:8082/input/delete/$inputId'));
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
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0288D1), Color(0xFF1A237E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Konfirmasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Anda yakin ingin menghapus input ini?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        deleteInput(inputId);
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Hapus'),
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
          editInput: editInput,
          inputId: inputId,
          existingData: existingData,
          komponenOptions: komponenOptions,
          selectedKomponen: selectedKomponen,
          // downloadFile: downloadFile,
        );
      },
    );
  }



  Future<Map<String, dynamic>> fetchExistingData(int inputId) async {
    final response =
    await http.get(Uri.parse('http://localhost:8082/input/find-by-id/$inputId'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      print('Gagal mengambil data');
      return {};
    }
  }

  // Function to handle the file download based on the file URL
  Future<void> downloadFile(int inputId) async {
    final url = Uri.parse('http://localhost:8082/input/download-by--input-id/$inputId');

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


  Future<void> createInput(Map<String, dynamic> inputData, List<Uint8List> fileBytesList, List<String> originalFileNames) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8082/input/create'),
    );

    // Add input data to request fields
    inputData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add multiple files with the key "files"
    for (int i = 0; i < fileBytesList.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files', // Use "files[]" as the key to indicate an array
          fileBytesList[i],
          filename: originalFileNames[i], // Use the original file name
          contentType: MediaType('application', 'octet-stream'),
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // final responseData = json.decode(response.body);
      fetchData(); // You can decide if you want to call fetchData here
    } else {
      print('Failed to create input');
    }
  }

  Future<void> editInput(int inputId, Map<String, dynamic> updatedData, List<Uint8List> fileBytesList,
      List<String> originalFileNames) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://localhost:8082/input/update/$inputId'),
    );

    // Add input data to request fields
    updatedData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add multiple files with the key "files"
    for (int i = 0; i < fileBytesList.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files', // Use "files[]" as the key to indicate an array
          fileBytesList[i],
          filename: originalFileNames[i], // Use the original file name
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Membuat shape box menjadi rounded
          ),
          elevation: 0, // Hapus bayangan dialog
          backgroundColor: Colors.transparent, // Hapus latar belakang dialog
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // Ganti latar belakang konten menjadi putih
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Agar konten berukuran sesuai dengan isinya
              children: [
                Text(
                  'Pilih Aksi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    showEditInputDialog(context, _inputList[index]['inputId']);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  icon: Icon(Icons.edit, size: 24, color: Colors.white),
                  label: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    confirmDeleteInput(_inputList[index]['inputId']);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  icon: Icon(Icons.delete, size: 24, color: Colors.white),
                  label: Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
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
        title: const Text('Daftar Input'),
      ),
      drawer: Submenu(
        onMenuItemSelected: _handleMenuItemSelected,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Empty container to adjust spacing
                Container(),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showCreateInputDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Input Baru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 16.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
                // Filter by year and category
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Filter by year dropdown
                        Container(
                          width: 200, // Adjust the width as needed
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: DropdownButton<String?>(
                            value: _selectedYear,
                            hint: const Text('Filter by year'),
                            onChanged: (value) {
                              print("Selected Year Changed: $value");
                              setState(() {
                                _selectedYear = value;
                                _filterInputList2();
                              });
                            },
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Show All :Tahun'),
                              ),
                              ..._yearList.map<DropdownMenuItem<String?>>((
                                  year) {
                                return DropdownMenuItem<String?>(
                                  value: year['tahun'],
                                  child: Text(year['tahun']),
                                );
                              }),
                            ],
                          ),
                        ),
                        // Filter by category dropdown
                        Container(
                          width: 200, // Adjust the width as needed
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: DropdownButton<String?>(
                            value: _selectedCategory,
                            hint: const Text('Filter by category'),
                            onChanged: (value) {
                              print("Selected Category Changed: $value");
                              setState(() {
                                _selectedCategory = value;
                                _filterInputList();
                              });
                            },
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Show All :kategori'),
                              ),
                              ..._categoryList.map<DropdownMenuItem<String?>>((
                                  category) {
                                return DropdownMenuItem<String?>(
                                  value: category['namaKategori'],
                                  child: Text(category['namaKategori']),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  dividerThickness: 1.0,
                  dataRowHeight: 250.0,
                  // columnSpacing: 12,
                  horizontalMargin: 12,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  border: TableBorder.all(
                    color: Colors.blue,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                  headingRowColor: MaterialStateColor.resolveWith((
                      states) => Colors.lightBlue),
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    fontFamily: 'Futuristic',
                  ),
                  dataRowColor: MaterialStateColor.resolveWith((
                      states) => Colors.grey[200] as Color),
                  dataTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                  columns: const [
                    DataColumn(
                      label: SizedBox(
                        width: 20, // Sesuaikan lebar kolom Inputid di sini
                        child: Text(
                          'ID',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign
                              .center, // Menyatukan teks ke tengah
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100, // Sesuaikan lebar kolom Pernyataan di sini
                        child: Text(
                          'Pernyataan',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign
                              .center, // Menyatukan teks ke tengah
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100, // Sesuaikan lebar kolom Pernyataan di sini
                        child: Text(
                          'Keterangan',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign
                              .center, // Menyatukan teks ke tengah
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 200, // Sesuaikan lebar kolom Pernyataan di sini
                        child: Text(
                          'File',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign
                              .center, // Menyatukan teks ke tengah
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        // Sesuaikan lebar kolom Pernyataan di sini
                        child: Text(
                          'Nilai',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign
                              .center, // Menyatukan teks ke tengah
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 50, // Sesuaikan lebar kolom Pernyataan di sini
                        child: Text(
                          'Bobot',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign
                              .right, // Menyatukan teks ke tengah
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        child: Text(
                          'NilaixBobot',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign
                              .right, // Menyatukan teks ke tengah
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Actions'),
                    ),
                  ],
                  rows: _inputList
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    dynamic input = entry.value;

                    int inputId = input['inputId'];
                    List<String> fileUrls = _fileUrls[inputId] ?? [];

                    // Create a list of file descriptions with their URLs
                    List<Widget> fileWidgets = [];
                    for (int i = 0; i < fileUrls.length; i++) {
                      fileWidgets.add(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'File ${i + 1}:',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Open the file URL here
                                if (fileUrls.isNotEmpty) {
                                  launch(fileUrls[i]);
                                }
                              },
                              child: Text(
                                fileUrls[i],
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 20,
                            // Sesuaikan lebar baris inputId sesuai kebutuhan
                            child: Text(
                              '${input['inputId']}',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            // Sesuaikan lebar baris Pernyataan sesuai kebutuhan
                            child: Text(
                              '${input['pernyataan']}',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            // Sesuaikan lebar baris nilai sesuai kebutuhan
                            child: Text(
                              '${input['keterangan']}',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 200,
                            // Sesuaikan lebar baris file sesuai kebutuhan
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: fileWidgets,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 30,
                            // Sesuaikan lebar baris nilai sesuai kebutuhan
                            child: Text(
                              '${input['nilai']}',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 50,
                            // Sesuaikan lebar baris Pernyataan sesuai kebutuhan
                            child: Text(
                              '${input['bobot']}',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text('${input['nilaixbobot']}')),
                        DataCell(Column(
                          children: [
                            SizedBox(height: 70.0), // Jarak vertikal antara baris data
                            ElevatedButton.icon(
                              onPressed: () {
                                showEditInputDialog(
                                    context, _inputList[index]['inputId']);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              icon: Icon(
                                  Icons.edit, size: 24, color: Colors.white),
                              label: Text(
                                'Edit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0), // Spasi vertikal
                            ElevatedButton.icon(
                              onPressed: () {
                                confirmDeleteInput(
                                    _inputList[index]['inputId']); // Konfirmasi sebelum menghapus
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              icon: Icon(
                                  Icons.delete, size: 24, color: Colors.white),
                              label: Text(
                                'Hapus',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                ),
                              ),
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
    );
  }





  Future<void> showCreateInputDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateInputDialog(
          createInput: createInput,
          komponenOptions: komponenOptions,
          selectedKomponen: selectedKomponen,
        );
      },
    );
  }
}

class CreateInputDialog extends StatefulWidget {
  final Function(Map<String, dynamic>, List<Uint8List>, List<String>) createInput;
  final List<Map<String, dynamic>> komponenOptions;
  final int selectedKomponen;

  const CreateInputDialog({
    Key? key,
    required this.createInput,
    required this.komponenOptions,
    required this.selectedKomponen,
  }) : super(key: key);

  @override
  _CreateInputDialogState createState() => _CreateInputDialogState();
}

class _CreateInputDialogState extends State<CreateInputDialog> {
  TextEditingController keteranganController = TextEditingController();
  List<Uint8List> fileBytesList = [];
  List<String> originalFileNames = [];
  int? _selectedKomponen;
  final _formKey = GlobalKey<FormState>();
  Color primaryColor = const Color(0xFF0288D1); // Google Blue
  Color secondaryColor = const Color(0xFF1A237E); // Google Green
  Color accentColor = const Color(0xF00BCD4); // Google Yellow
  Color backgroundColor = const Color(0xFF282828); // Dark Gray

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: FractionallySizedBox(
        widthFactor: 0.6, // Adjust the width factor as needed
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Buat Input Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: keteranganController,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  cursorColor: Colors.white,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedKomponen,
                  items: widget.komponenOptions.map((komponen) {
                    return DropdownMenuItem<int>(
                      value: komponen['komponenId'],
                      child: Text(
                        komponen['pernyataan'],
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKomponen = value;
                    });
                  },
                  dropdownColor: Color(0xFF1A237E),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Komponen',
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return "Please select a Komponen";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
                      if (result != null) {
                        for (final file in result.files) {
                          setState(() {
                            fileBytesList.add(file.bytes!);
                            originalFileNames.add(file.name);
                          });
                        }
                      }
                    } else {
                      print('Invalid Input');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_file, color: Colors.white),
                      SizedBox(width: 8.0),
                      Text('Pilih File', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Preview of selected files
// Preview of selected files
                if (originalFileNames.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Files:',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 120.0,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: originalFileNames.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                originalFileNames[index],
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    fileBytesList.removeAt(index);
                                    originalFileNames.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      if (originalFileNames.length > 1)
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Files'),
                                  content: SizedBox(
                                    height: 200.0,
                                    width: 300.0,
                                    child: ListView.builder(
                                      itemCount: originalFileNames.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return ListTile(
                                          title: Text(originalFileNames[index]),
                                        );
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'View All Files',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Create a map with the input data
                      Map<String, dynamic> inputData = {
                        'keterangan': keteranganController.text,
                        'komponenId': _selectedKomponen,
                      };

                      // Call the createInput function and pass the data
                      widget.createInput(inputData, fileBytesList, originalFileNames);

                      // Close the dialog
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}










class EditInputDialog extends StatefulWidget {
  final int inputId;
  final Map<String, dynamic> existingData;
  final Future<void> Function(int, Map<String, dynamic>, List<Uint8List>, List<String>) editInput;
  final List<Map<String, dynamic>> komponenOptions;
  final int selectedKomponen;

  const EditInputDialog({
    Key? key,
    required this.inputId,
    required this.existingData,
    required this.editInput,
    required this.komponenOptions,
    required this.selectedKomponen,
  }) : super(key: key);

  @override
  _EditInputDialogState createState() => _EditInputDialogState();
}

class _EditInputDialogState extends State<EditInputDialog> {
  TextEditingController keteranganController = TextEditingController();
  int? _selectedKomponen;
  List<Uint8List> fileBytesList = [];
  List<String> originalFileNames = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    keteranganController.text = widget.existingData['keterangan'].toString();
    _selectedKomponen = widget.selectedKomponen;
    // Mengambil daftar file dari respons backend
    List<Map<String, dynamic>> files = List<Map<String, dynamic>>.from(widget.existingData['file']);
    // Mengambil nama file dari setiap objek dalam daftar
    List<String> originalFileNames = files.map((file) => file['file'].toString()).toList();


  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0288D1), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Input',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: keteranganController,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedKomponen,
                  items: widget.komponenOptions.map((komponen) {
                    return DropdownMenuItem<int>(
                      value: komponen['komponenId'],
                      child: Text(
                        komponen['pernyataan'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKomponen = value;
                    });
                  },
                  dropdownColor: Color(0xFF1A237E),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Komponen',
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return "Please select a Komponen";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
                      if (result != null) {
                        for (final file in result.files) {
                          setState(() {
                            fileBytesList.add(file.bytes!);
                            originalFileNames.add(file.name);
                          });
                        }
                      }
                    } else {
                      print('Invalid Input');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Pilih File'),
                ),
                const SizedBox(height: 16.0),
                // Preview of selected files
                if (originalFileNames.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Files:',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 120.0,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: originalFileNames.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                originalFileNames[index],
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    fileBytesList.removeAt(index);
                                    originalFileNames.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      if (originalFileNames.length > 1)
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Files'),
                                  content: SizedBox(
                                    height: 200.0,
                                    width: 300.0,
                                    child: ListView.builder(
                                      itemCount: originalFileNames.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return ListTile(
                                          title: Text(originalFileNames[index]),
                                        );
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            textStyle: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 32.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'View All Files',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && fileBytesList.isNotEmpty) {
                      Map<String, dynamic> updatedData = {
                        'keterangan': keteranganController.text,
                        'komponenId': _selectedKomponen,
                        'file': originalFileNames,
                      };
                      widget.editInput(
                        widget.inputId,
                        updatedData,
                        fileBytesList,
                        originalFileNames,
                      );
                      Navigator.of(context).pop();
                    } else {
                      print('Invalid Input or No Files Selected');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






