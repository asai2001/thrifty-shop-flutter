import 'package:flutter/material.dart';
import 'package:fluttter_akreditasi/submenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KategoriElemenPage extends StatefulWidget {
  const KategoriElemenPage({super.key});

  @override
  _KategoriElemenPageState createState() => _KategoriElemenPageState();
}


class _KategoriElemenPageState extends State<KategoriElemenPage> {
  List<dynamic> _kategoriElemenList = [];
  List<Map<String, dynamic>> _tahunList = [];
  String selectedTahun = "0";


  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchData();
    _fetchTahunList().then((tahunList) {
      if (tahunList.isNotEmpty) {
        setState(() {
          _tahunList = tahunList;
          selectedTahun = _tahunList[0]['tahunId'];
        });
      }
    });
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




  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse('http://localhost:8089/vw-elemen/get-all'));
    if (response.statusCode == 200) {
      setState(() {
        _kategoriElemenList = json.decode(response.body) as List<dynamic>;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTahunList() async {
    final response = await http.get(Uri.parse('http://localhost:8089/tahun/find-all'));
    if (response.statusCode == 200) {
      List<dynamic> tahunList = json.decode(response.body) as List<dynamic>;
      return tahunList.map((tahun) => tahun as Map<String, dynamic>).toList();
    } else {
      // Show an error message or handle the error
      print('Failed to fetch tahun list');
      return [];
    }
  }

  void _handleMenuItemSelected(String menu) {
    // Implement the logic based on the selected menu
    // For example, you can navigate to different pages or perform specific actions.
    print('Selected menu: $menu');
  }



  Future<void> deleteKategoriElemen(String kategoriElemenId) async {
    final response = await http.delete(
        Uri.parse('http://localhost:8089/elemen/delete/$kategoriElemenId'));
    if (response.statusCode == 200) {
      // Refresh the data after successful deletion
      fetchData();
    } else {
      // Show an error message or handle the error
      print('Failed to delete kategori elemen');
    }
  }

  Future<void> confirmDeleteKategoriElemen(String kategoriElemenId) async {
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
                  'Anda yakin ingin menghapus kategori elemen ini?',
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
                        deleteKategoriElemen(kategoriElemenId);
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

  void showEditKategoriElemenDialog(BuildContext context, String kategoriElemenId) async {
    Map<String, dynamic> existingData = await fetchExistingData(kategoriElemenId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          kategoriElemenId: kategoriElemenId,
          existingData: existingData,
          editKategoriElemen: editKategoriElemen,
          selectedtahun: selectedTahun,
          tahunList: _tahunList,

        );
      },
    );
  }

  Future<void> createKategoriElemen(Map<String, dynamic> kategoriElemenData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? prodiId = prefs.getString('prodiId');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8089/elemen/create'),
    );

    // Tambahkan prodiId ke data tahun
    kategoriElemenData['prodiId'] = prodiId;
    // Add the komponenData as multipart/form-data
    kategoriElemenData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Refresh the data after successful creation
      fetchData();
    } else {
      // Show an error message or handle the error
      print('Failed to create kategori elemen');
    }
  }

  Future<Map<String, dynamic>> fetchExistingData(String kategoriElemenId) async {
    final response = await http.get(
        Uri.parse('http://localhost:8089/elemen/find-by-id/$kategoriElemenId'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Show an error message or handle the error
      print('Failed to fetch existing data');
      return {};
    }
  }

  Future<void> editKategoriElemen(String kategoriElemenId,
      Map<String, dynamic> updatedData) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://localhost:8089/elemen/update/$kategoriElemenId'),
    );

    // Add input data to request fields
    updatedData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Simpan prodiId dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? prodiId = prefs.getString('prodiId');
    if (prodiId != null) {
      request.fields['prodiId'] = prodiId;
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Refresh the data after successful update
      fetchData();
    } else {
      // Show an error message or handle the error
      print('Failed to update kategori elemen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kriteria'),
      ),
      drawer: Submenu(
        onMenuItemSelected: _handleMenuItemSelected,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showCreateKategoriElemenDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Kriteria Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                textStyle: const TextStyle(fontSize: 16.0),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.0),
                    ),

                    headingRowColor: MaterialStateColor.resolveWith((
                        states) => Colors.indigo),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    dataRowColor: MaterialStateColor.resolveWith((
                        states) => Colors.grey[400] as Color),
                    dataTextStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                    columns: const [
                      DataColumn2(
                        label: Text(
                          'NO',
                        ),
                      ),
                      DataColumn2(
                        label: Text(
                          'Nama Kriteria',
                        ),
                      ),
                      DataColumn2(
                        label: Text(
                          'Tahun',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Actions',
                        ),
                      ),
                    ],
                    rows: _kategoriElemenList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> kategoriElemen = entry.value;
                      int sequentialNumber = _kategoriElemenList.length - index;

                      return DataRow(
                        cells: [
                          DataCell(Text(
                            '$sequentialNumber', // Sequential number
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text('${kategoriElemen['namaKategori']}')),
                          DataCell(Text('${kategoriElemen['tahun']}')),
                          DataCell(Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showEditKategoriElemenDialog(context, kategoriElemen['kategoriElemenId']);
                                },
                                child: const Text('Edit'),
                              ),
                              const SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  confirmDeleteKategoriElemen(kategoriElemen['kategoriElemenId']); // Confirm before deleting
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
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

  Future<void> showCreateKategoriElemenDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateKategoriElemenDialog(
          createKategoriElemen: createKategoriElemen,
          // kategoriElemenList: _kategoriElemenList,
          tahunList: _tahunList,
          selectedtahun: selectedTahun,
        );
      },
    );
  }
}

class CustomDialog extends StatefulWidget {
  final String kategoriElemenId;
  final Map<String, dynamic> existingData;
  final Function(String, Map<String, dynamic>) editKategoriElemen;
  final List<Map<String, dynamic>> tahunList;
  final String selectedtahun; // Make it nullable

  const CustomDialog({
    Key? key,
    required this.kategoriElemenId,
    required this.existingData,
    required this.editKategoriElemen,
    required this.selectedtahun,
    required this.tahunList,
  }) : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late TextEditingController _namaKategoriController;
  late TextEditingController _tahunController;
  String? _selectedTahun;

  @override
  void initState() {
    super.initState();
    _namaKategoriController = TextEditingController(
      text: widget.existingData['namaKategori'].toString(),
    );
    _selectedTahun = widget.existingData['tahunId'];
    // _selectedTahun = widget.selectedtahun;
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
              colors: [Color(0xFF3840AB), Color(0xFF1A237E)],
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
                'Edit Kriteria',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                controller: _namaKategoriController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama Kriteria',
                  labelStyle: const TextStyle(color: Colors.white),
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
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedTahun,
                items: widget.tahunList.map((tahun) {
                  return DropdownMenuItem<String>(
                    value: tahun['tahunId'],
                    child: Text(
                      tahun['tahun'],
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 16.0),
                    ),
                  );
                }).toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    _selectedTahun =
                    selectedValue!; // Update the local variable
                  });
                },
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
                dropdownColor: Color(0xFF1A237E),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                elevation: 2,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Tahun',
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
                    return "Please select a tahun";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> updatedData = {
                    'namaKategori': _namaKategoriController.text,
                    'tahunId': _selectedTahun,
                  };
                  widget.editKategoriElemen(
                      widget.kategoriElemenId, updatedData);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
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
    );
  }
}

class CreateKategoriElemenDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) createKategoriElemen;
  final List<Map<String, dynamic>> tahunList;
  final String selectedtahun;

  const CreateKategoriElemenDialog({super.key, 
    required this.createKategoriElemen,
    required this.tahunList,
    required this.selectedtahun,
  });

  @override
  _CreateKategoriElemenDialogState createState() =>
      _CreateKategoriElemenDialogState();
}

class _CreateKategoriElemenDialogState
    extends State<CreateKategoriElemenDialog> {
  late TextEditingController _namaKategoriController;
  String? _selectedTahun;

  @override
  void initState() {
    super.initState();
    _namaKategoriController = TextEditingController();
    _selectedTahun = widget.selectedtahun;
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
              colors: [Color(0xFF3840AB), Color(0xFF1A237E)],
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
                'Buat Kriteria Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                controller: _namaKategoriController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama Kriteria',
                  labelStyle: const TextStyle(color: Colors.white),
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
              ),
              const SizedBox(height: 16.0),


              DropdownButtonFormField<String>(
                value: _selectedTahun,
                items: widget.tahunList.map((tahun) {
                  return DropdownMenuItem<String>(
                    value: tahun['tahunId'],
                    child: Text(
                      tahun['tahun'],
                      style: GoogleFonts.poppins(color: Colors.white,
                          fontSize: 16.0),
                    ),
                  );
                }).toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    _selectedTahun = selectedValue; // Update the local variable
                  });
                },
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
                dropdownColor: Color(0xFF1A237E),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                elevation: 2,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Tahun',
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
                    return "Please select a tahun";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  String kategori = _namaKategoriController.text;
                  if (kategori.isNotEmpty) {
                    Map<String, dynamic> kategoriElemenData = {
                      'namaKategori': _namaKategoriController.text,
                      'tahunId': _selectedTahun,
                    };
                    widget.createKategoriElemen(kategoriElemenData);
                    Navigator.of(context).pop();
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column( // Menggunakan Column untuk teks berada di atas
                          children: [
                            Text(
                              'Data tidak boleh kosong!',
                              style: TextStyle(
                                color: Colors.white, // Warna teks
                                fontSize: 16.0, // Ukuran teks
                              ),
                            ),
                            // Tambahkan widget lain jika diperlukan di bawah teks
                          ],
                        ),
                        backgroundColor: Colors.red, // Warna latar belakang
                        duration: Duration(seconds: 3), // Durasi tampilan pesan
                      ),
                    );
                  }
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
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
    );
  }
}
