import 'package:flutter/material.dart';
import 'package:fluttter_akreditasi/submenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KomponenPage extends StatefulWidget {
  const KomponenPage({super.key});

  @override
  _KomponenPageState createState() => _KomponenPageState();
}

class _KomponenPageState extends State<KomponenPage> {
  List<dynamic> _komponenList = [];
  List<Map<String, dynamic>> _kategoriElemenList = [];
  int selectedKategoriElemen = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchKategoriElemenList().then((kategoriList) {
      if (kategoriList.isNotEmpty) {
        setState(() {
          _kategoriElemenList = kategoriList;
          selectedKategoriElemen = _kategoriElemenList[0]['kategoriElemenId'];
        });
      }
    });
  }

  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse('http://localhost:8082/komponen/vw-find-all'));
    if (response.statusCode == 200) {
      setState(() {
        _komponenList = json.decode(response.body) as List<dynamic>;
      });
    }
  }

  void _handleMenuItemSelected(String menu) {
    // Implement the logic based on the selected menu
    // For example, you can navigate to different pages or perform specific actions.
    print('Selected menu: $menu');
  }

  Future<void> deleteKomponen(int komponenId) async {
    final response = await http.delete(
        Uri.parse('http://localhost:8082/komponen/delete/$komponenId'));
    if (response.statusCode == 200) {
      // Refresh the data after successful deletion
      fetchData();
    } else {
      // Show an error message or handle the error
      print('Failed to delete komponen');
    }
  }

  Future<void> confirmDeleteKomponen(int komponenId) async {
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
                  'Anda yakin ingin menghapus komponen ini?',
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
                        deleteKomponen(komponenId); // Convert komponenId to a string
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


  void showEditKomponenDialog(BuildContext context, int komponenId) async {
    Map<String, dynamic> existingData = await fetchExistingData(komponenId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          komponenId: komponenId,
          existingData: existingData,
          editKomponen: editKomponen,
          kategoriElemenList: _kategoriElemenList, // Pass the _kategoriElemenList here
          selectedKategoriElemen: selectedKategoriElemen, // Pass the selectedKategoriElemen here
        );
      },
    );
  }


  Future<void> createKomponen(Map<String, dynamic> komponenData) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8082/komponen/create'),
    );

    // Add the komponenData as multipart/form-data
    komponenData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Refresh the data after successful creation
      fetchData();
    } else {
      // Show an error message or handle the error
      print('Failed to create komponen');
    }
  }

  Future<Map<String, dynamic>> fetchExistingData(int komponenId) async {
    final response = await http.get(
        Uri.parse('http://localhost:8082/komponen/find-by-id/$komponenId'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Show an error message or handle the error
      print('Failed to fetch existing data');
      return {};
    }
  }

  Future<void> editKomponen(int komponenId,
      Map<String, dynamic> updatedData) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://localhost:8082/komponen/update/$komponenId'),
    );

    // Add the updated fields as multipart/form-data
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
      print('Failed to update komponen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Komponen'),
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
                showCreateKomponenDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Komponen Baru'),
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
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: DataTable(
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
                      DataColumn(
                        label: Text(
                          'Komponen ID',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Nama Kategori',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Nilai',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Bobot',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'NilaixBobot',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Pernyataan',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Actions',
                        ),
                      ),
                    ],
                    // Ubah _komponenList menjadi data yang sesuai
                    rows: _komponenList.map((komponen) {
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            '${komponen['komponenId']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text('${komponen['namaKategori']}')),
                          DataCell(Text('${komponen['nilai']}')),
                          DataCell(Text('${komponen['bobot']}')),
                          DataCell(Text('${komponen['nilaixbobot']}')),
                          DataCell(Text('${komponen['pernyataan']}')),
                          DataCell(Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showEditKomponenDialog(
                                      context, komponen['komponenId']);
                                },
                                child: const Text('Edit'),
                              ),
                              const SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  confirmDeleteKomponen(
                                      komponen['komponenId']); // Confirm before deleting
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

  Future<void> showCreateKomponenDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateKomponenDialog(
          createKomponen: createKomponen,
          kategoriElemenList: _kategoriElemenList,
          // Pass the _kategoriElemenList here
          selectedKategoriElemen: selectedKategoriElemen, // Pass the selectedKategoriElemen here
        );
      },
    );
  }
}

Future<List<Map<String, dynamic>>> _fetchKategoriElemenList() async {
  final response = await http.get(Uri.parse('http://localhost:8082/vw-elemen/get-all'));
  if (response.statusCode == 200) {
    List<dynamic> kategoriElemenList = json.decode(response.body) as List<dynamic>;
    return kategoriElemenList.map((kategori) => kategori as Map<String, dynamic>).toList();
  } else {
    // Show an error message or handle the error
    print('Failed to fetch kategori elemen list');
    return [];
  }
}


class CustomDialog extends StatefulWidget {
  final int komponenId;
  final Map<String, dynamic> existingData;
  final Function(int, Map<String, dynamic>) editKomponen;
  final List<Map<String, dynamic>> kategoriElemenList;
  final int selectedKategoriElemen;

  const CustomDialog({super.key, 
    required this.komponenId,
    required this.existingData,
    required this.editKomponen,
    required this.kategoriElemenList,
    required this.selectedKategoriElemen,
  });

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late int _selectedKategoriElemen;

  @override
  void initState() {
    super.initState();
    _selectedKategoriElemen = widget.selectedKategoriElemen;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nilaiController = TextEditingController(
      text: widget.existingData['nilai'].toString(),
    );
    TextEditingController bobotController = TextEditingController(
      text: widget.existingData['bobot'].toString(),
    );
    TextEditingController pernyataanController = TextEditingController(
      text: widget.existingData['pernyataan'].toString(),
    );

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
              Text(
                'Edit Komponen',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              DropdownButtonFormField<int>(
                value: _selectedKategoriElemen,
                items: widget.kategoriElemenList.map((kategori) {
                  return DropdownMenuItem<int>(
                    value: kategori['kategoriElemenId'],
                    child: Text(
                      kategori['namaKategori'],
                      style: GoogleFonts.poppins(color: Colors.white,
                          fontSize: 16.0),
                    ),
                  );
                }).toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    _selectedKategoriElemen = selectedValue!;
                  });
                },
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
                dropdownColor: Color(0xFF1A237E),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                elevation: 2,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Kategori Elemen',
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
                    return "Please select a elemen";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: nilaiController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nilai',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
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
                cursorColor: Colors.white, // Cursor color will be white
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: bobotController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Bobot',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
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
                cursorColor: Colors.white, // Cursor color will be white
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: pernyataanController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Pernyataan',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
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
                cursorColor: Colors.white, // Cursor color will be white
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> updatedData = {
                    'kategoriElemen': _selectedKategoriElemen,
                    'nilai': nilaiController.text,
                    'bobot': bobotController.text,
                    'pernyataan': pernyataanController.text,
                  };
                  widget.editKomponen(widget.komponenId, updatedData);
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle: GoogleFonts.poppins(
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


class CreateKomponenDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) createKomponen;
  final List<Map<String, dynamic>> kategoriElemenList;
  final int selectedKategoriElemen;

  const CreateKomponenDialog({super.key, 
    required this.createKomponen,
    required this.kategoriElemenList,
    required this.selectedKategoriElemen,
  });

  @override
  _CreateKomponenDialogState createState() => _CreateKomponenDialogState();
}

class _CreateKomponenDialogState extends State<CreateKomponenDialog> {
  int? _selectedKategoriElemen;

  @override
  void initState() {
    super.initState();
    _selectedKategoriElemen = widget.selectedKategoriElemen;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nilaiController = TextEditingController();
    TextEditingController bobotController = TextEditingController();
    TextEditingController pernyataanController = TextEditingController();

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
              Text(
                'Buat Komponen Baru',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              DropdownButtonFormField<int>(
                value: _selectedKategoriElemen,
                items: widget.kategoriElemenList.map((kategori) {
                  return DropdownMenuItem<int>(
                    value: kategori['kategoriElemenId'],
                    child: Text(
                      kategori['namaKategori'],
                      style: GoogleFonts.poppins(color: Colors.white,
                          fontSize: 16.0),
                    ),
                  );
                }).toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    _selectedKategoriElemen =
                        selectedValue; // Update the local variable
                  });
                },
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
                dropdownColor: Color(0xFF1A237E),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                elevation: 2,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Kategori Elemen',
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
                    return "Please select a elemen";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: nilaiController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nilai',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
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
                cursorColor: Colors.white, // Cursor color will be white
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: bobotController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Bobot',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
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
                cursorColor: Colors.white, // Cursor color will be white
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: pernyataanController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Pernyataan',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
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
                cursorColor: Colors.white, // Cursor color will be white
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> komponenData = {
                    'kategoriElemen': _selectedKategoriElemen,
                    'nilai': nilaiController.text,
                    'bobot': bobotController.text,
                    'pernyataan': pernyataanController.text,
                  };
                  widget.createKomponen(komponenData);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle: GoogleFonts.poppins(
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