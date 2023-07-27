import 'package:flutter/material.dart';
import 'package:fluttter_akreditasi/submenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';

class KategoriElemenPage extends StatefulWidget {
  @override
  _KategoriElemenPageState createState() => _KategoriElemenPageState();
}

class _KategoriElemenPageState extends State<KategoriElemenPage> {
  List<dynamic> _kategoriElemenList = [];
  List<Map<String, dynamic>>  _tahunList = [];
  int selectedTahun= 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse('http://localhost:8081/vw-elemen/get-all'));
    if (response.statusCode == 200) {
      setState(() {
        _kategoriElemenList = json.decode(response.body) as List<dynamic>;
      });
    }
  }

  void _handleMenuItemSelected(String menu) {
    // Implement the logic based on the selected menu
    // For example, you can navigate to different pages or perform specific actions.
    print('Selected menu: $menu');
  }



  Future<void> deleteKategoriElemen(int kategoriElemenId) async {
    final response = await http.delete(
        Uri.parse('http://localhost:8081/elemen/delete/$kategoriElemenId'));
    if (response.statusCode == 200) {
      // Refresh the data after successful deletion
      fetchData();
    } else {
      // Show an error message or handle the error
      print('Failed to delete kategori elemen');
    }
  }

  Future<void> confirmDeleteKategoriElemen(int kategoriElemenId) async {
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
                  'Anda yakin ingin menghapus kategori elemen ini?',
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
                        deleteKategoriElemen(kategoriElemenId);
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

  void showEditKategoriElemenDialog(BuildContext context, int kategoriElemenId) async {
    Map<String, dynamic> existingData = await fetchExistingData(kategoriElemenId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          kategoriElemenId: kategoriElemenId,
          existingData: existingData,
          editKategoriElemen: editKategoriElemen,
        );
      },
    );
  }

  Future<void> createKategoriElemen(Map<String, dynamic> kategoriElemenData) async {
    final response = await http.post(
      Uri.parse('http://localhost:8081/elemen/create'),
      body: json.encode(kategoriElemenData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Refresh the data after successful creation
      fetchData();
    } else {
      // Show an error message or handle the error
      print('Failed to create kategori elemen');
    }
  }

  Future<Map<String, dynamic>> fetchExistingData(int kategoriElemenId) async {
    final response = await http.get(
        Uri.parse('http://localhost:8081/elemen/find-by-id/$kategoriElemenId'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Show an error message or handle the error
      print('Failed to fetch existing data');
      return {};
    }
  }

  Future<void> editKategoriElemen(int kategoriElemenId,
      Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('http://localhost:8081/elemen/update/$kategoriElemenId'),
      body: json.encode(updatedData),
      headers: {'Content-Type': 'application/json'},
    );

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
        title: Text('Daftar Kategori Elemen'),
      ),
      drawer: Submenu(
        onMenuItemSelected: _handleMenuItemSelected,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showCreateKategoriElemenDialog(context);
              },
              icon: Icon(Icons.add),
              label: Text('Buat Kategori Elemen Baru'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                textStyle: TextStyle(fontSize: 16.0),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    headingRowColor: MaterialStateColor.resolveWith((
                        states) => Colors.blue as Color),
                    headingTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    dataRowColor: MaterialStateColor.resolveWith((
                        states) => Colors.grey[800] as Color),
                    dataTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    columns: [
                      DataColumn2(
                        label: Text(
                          'Kategori Elemen ID',
                        ),
                      ),
                      DataColumn2(
                        label: Text(
                          'Nama Kategori',
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
                    rows: _kategoriElemenList.map((kategoriElemen) {
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            '${kategoriElemen['kategoriElemenId']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text('${kategoriElemen['namaKategori']}')),
                          DataCell(Text('${kategoriElemen['tahun']}')),
                          DataCell(Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showEditKategoriElemenDialog(
                                      context, kategoriElemen['kategoriElemenId']);
                                },
                                child: Text('Edit'),
                              ),
                              SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  confirmDeleteKategoriElemen(
                                      kategoriElemen['kategoriElemenId']); // Confirm before deleting
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                ),
                                child: Text('Delete'),
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
  final int kategoriElemenId;
  final Map<String, dynamic> existingData;
  final Function(int, Map<String, dynamic>) editKategoriElemen;

  CustomDialog({
    required this.kategoriElemenId,
    required this.existingData,
    required this.editKategoriElemen,
  });

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late TextEditingController _namaKategoriController;
  late TextEditingController _tahunController;

  @override
  void initState() {
    super.initState();
    _namaKategoriController = TextEditingController(
      text: widget.existingData['namaKategori'].toString(),
    );
    _tahunController = TextEditingController(
      text: widget.existingData['tahun'].toString(),
    );
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
              'Edit Kategori Elemen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.0),
            TextFormField(
              controller: _namaKategoriController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                labelStyle: TextStyle(color: Colors.white),
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
              cursorColor: Colors.white,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _tahunController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tahun',
                labelStyle: TextStyle(color: Colors.white),
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
              cursorColor: Colors.white,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> updatedData = {
                  'namaKategori': _namaKategoriController.text,
                  'tahun': int.parse(_tahunController.text),
                };
                widget.editKategoriElemen(
                    widget.kategoriElemenId, updatedData);
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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

class CreateKategoriElemenDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) createKategoriElemen;
  final List<Map<String, dynamic>> tahunList;
  final int selectedtahun;

  CreateKategoriElemenDialog({
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
  int? _selectedTahun;

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
              'Buat Kategori Elemen Baru',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.0),
            TextFormField(
              controller: _namaKategoriController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                labelStyle: TextStyle(color: Colors.white),
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
              cursorColor: Colors.white,
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<int>(
              value: _selectedTahun,
              items: widget.tahunList.map((tahun) {
                return DropdownMenuItem<int>(
                  value: tahun['tahunId'],
                  child: Text(
                    tahun['tahun'],
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
                  ),
                );
              }).toList(),
              onChanged: (selectedValue) {
                setState(() {
                  _selectedTahun = selectedValue; // Update the local variable
                });
              },
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              dropdownColor: Colors.blueGrey[800],
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              elevation: 2,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Tahun',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> kategoriElemenData = {
                  'namaKategori': _namaKategoriController.text,
                  'tahun': _selectedTahun,
                };
                widget.createKategoriElemen(kategoriElemenData);
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
