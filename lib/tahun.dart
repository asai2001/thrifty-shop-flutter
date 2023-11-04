import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:fluttter_akreditasi/submenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class TahunPage extends StatefulWidget {
  const TahunPage({super.key});


  @override
  _TahunPageState createState() => _TahunPageState();
}


class _TahunPageState extends State<TahunPage> {
  late List<Map<String, dynamic>> _tahunList = []; // Inisialisasi dengan list kosong


  @override
  void initState() {
    super.initState();
    _getTahunList();
  }

  Future<void> _getTahunList() async {
    final response = await http.get(Uri.parse('http://localhost:8082/tahun/find-all'));
    if (response.statusCode == 200) {
      final List<dynamic> decodedJson = jsonDecode(response.body);
      setState(() {
        _tahunList = decodedJson.cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }


  Future<void> createTahun(Map<String, dynamic> tahunData) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8082/tahun/create'),
    );

    // Add the komponenData as multipart/form-data
    tahunData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Tahun created successfully
      // You can add any additional logic here
      _getTahunList();
    } else {
      // Error creating Tahun
      // You can handle the error or display a message to the user
    }
  }


  void _handleMenuItemSelected(String menu) {
    // Implement the logic based on the selected menu
    // For example, you can navigate to different pages or perform specific actions.
    print('Selected menu: $menu');
  }

  Future<void> showCreateTahunDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateTahunDialog(
            createTahun: createTahun,
            tahunList : _tahunList
        );
      },
    );
  }


  Future<void> deleteTahun(String tahunId) async {
    final response = await http.delete(
        Uri.parse('http://localhost:8082/tahun/delete/$tahunId'));
    if (response.statusCode == 200) {
      // Refresh the data after successful deletion
      _getTahunList();
    } else {
      // Show an error message or handle the error
      print('Failed to delete kategori elemen');
    }
  }

  Future<void> confirmDeleteTahun(String tahunId) async {
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
                  'Anda yakin ingin menghapus tahun ini?',
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
                        deleteTahun(tahunId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tahun'),
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
                showCreateTahunDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Tahun Baru'),
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
                    dataRowHeight: 60,
                    headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.indigo),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    dataRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey[400] as Color),
                    dataTextStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                    columns: generateDataColumns(_tahunList),
                    rows: _tahunList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> tahun = entry.value;
                      int sequentialNumber = _tahunList.length - index;
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            '$sequentialNumber',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )),
                          DataCell(Text(
                            '${tahun['tahun']}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          )),
                          DataCell(Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showEditTahunDialog(context, tahun['tahunId']);
                                },
                                child: const Text('Edit'),
                              ),
                              const SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  confirmDeleteTahun(tahun['tahunId']); // Confirm before deleting
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

  List<DataColumn2> generateDataColumns(List<Map<String, dynamic>> tahunList) {
    List<DataColumn2> columns = [
      DataColumn2(
        label: Text(
          'No',
        ),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text(
          'Tahun',
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


  Future<Map<String, dynamic>> fetchExistingData(String tahunId) async {
    final response = await http.get(
        Uri.parse('http://localhost:8082/tahun/find-by-id/$tahunId'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Show an error message or handle the error
      print('Failed to fetch existing data');
      return {};
    }
  }

  Future<void> edittahun(String tahunId,
      Map<String, dynamic> updatedData) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://localhost:8082/tahun/update/$tahunId'),
    );

    // Add input data to request fields
    updatedData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Refresh the data after successful update
      _getTahunList();
    } else {
      // Show an error message or handle the error
      print('Failed to update kategori elemen');
    }
  }

  void showEditTahunDialog(BuildContext context, String tahunId) async {
    Map<String, dynamic> existingData = await fetchExistingData(tahunId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          tahunId: tahunId,
          existingData: existingData,
          editTahun: edittahun,
        );
      },
    );
  }

}

class CustomDialog extends StatefulWidget {
  final String tahunId;
  final Map<String, dynamic> existingData;
  final Function(String, Map<String, dynamic>) editTahun;

  const CustomDialog({
    Key? key,
    required this.tahunId,
    required this.existingData,
    required this.editTahun,
  }) : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  // late TextEditingController _namaKategoriController;
  late TextEditingController _tahunController;


  @override
  void initState() {
    super.initState();
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
                'Edit Tahun',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                controller: _tahunController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tahun',
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
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> updatedData = {
                    'tahun': _tahunController.text,
                  };
                  widget.editTahun(
                      widget.tahunId, updatedData);
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



class CreateTahunDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) createTahun;
  final List<Map<String, dynamic>> tahunList;

  const CreateTahunDialog({
    Key? key,
    required this.createTahun,
    required this.tahunList,
  }) : super(key: key);

  @override
  _CreateTahunDialogState createState() => _CreateTahunDialogState();
}

class _CreateTahunDialogState extends State<CreateTahunDialog> {
  @override
  Widget build(BuildContext context) {
    TextEditingController tahunController = TextEditingController();

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
                'Buat Tahun Baru',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                controller: tahunController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tahun',
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
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> tahunData = {
                    'tahun': tahunController.text,
                  };
                  widget.createTahun(tahunData);
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