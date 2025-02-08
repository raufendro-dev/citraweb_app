import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/main.dart';
import 'package:mikrotik/screens/pilih_alamat_screen.dart';
import 'package:mikrotik/services/auth_service.dart';

class AddressFormScreen extends StatefulWidget {
  @override
  _AddressFormScreenState createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _perusahaanController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _kodePosController = TextEditingController();
  final TextEditingController _notelpController = TextEditingController();
  final TextEditingController _notelpKodeNegaraController =
      TextEditingController();
  final TextEditingController _notelpKodeDaerahController =
      TextEditingController();
  final TextEditingController _nohpController = TextEditingController();
  final TextEditingController _kotalainController = TextEditingController();

  String? selectedCity;
  List<Map<String, dynamic>> cities = [];

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  InputDecoration getInputDecoration() {
    return const InputDecoration(
      isDense: true,
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      border: OutlineInputBorder(),
    );
  }

  List<String> _kota = [];
  List<String> _idkota = [];

  Future<void> fetchCities() async {
    final response = await http.get(Uri.parse(Config.baseUrlApi +
        '/app-api/kota/?key=0cc7da679bea04fea453c8062e06514d'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey("data") && responseData["data"] is List) {
        setState(() {
          cities = List<Map<String, dynamic>>.from(responseData["data"]);
        });
      }
      for (var i = 0; i < cities.length; i++) {
        _kota.add(cities[i]['nama_kota']);
        _idkota.add(cities[i]['id']);
      }
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent user from dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Center content horizontally
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text('Menyimpan alamat'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> submitForm() async {
    showLoadingDialog();
    String id = await AuthService().idUser;
    String sessionI = await AuthService().sessId;
    String ip = await AuthService.getIPAddress();
    if (!_formKey.currentState!.validate()) {
      Navigator.pop(context);
      return;
    }

    final url =
        Uri.parse(Config.baseUrlApi + '/app-api/keranjang/alamat-tujuan-baru/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "key": "0cc7da679bea04fea453c8062e06514d",
        "iduser": id,
        "sess_id": sessionI,
        "ip": ip,
        "nama": _namaController.text,
        "perusahaan": _perusahaanController.text,
        "alamat": _alamatController.text,
        "kota_id": selectedCity,
        "kota_lain": _kotalainController.text,
        "kodepos": _kodePosController.text,
        "kode_telp_negara": _notelpKodeNegaraController.text,
        "kode_telp_daerah": _notelpKodeDaerahController.text,
        "notelp": _notelpController.text,
        "nohp": _nohpController.text
      }),
    );

    if (response.statusCode == 200) {
      print('Form submitted successfully');
      Navigator.pop(context);
      Navigator.of(context).pop(true);
    } else {
      Navigator.pop(context);
      print('Failed to submit form');
    }
  }

  Route _createRoute(page, slideDirection direction) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        const end = Offset.zero;
        if (direction == slideDirection.toLeft) {
          begin = const Offset(1.0, 0.0);
        } else {
          begin = const Offset(0.0, 1.0);
        }
        const curve = Curves.linear;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return Stack(
          children: [
            SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Alamat Tujuan')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Alamat Tujuan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "Anda dapat mengirimkan pesanan Anda ke alamat selain alamat yang terdaftar di data personal Anda. Untuk mendaftarkan alamat pengiriman alternatif yang baru, gunakanlah form di bawah ini."),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "Isilah form berikut ini dengan lengkap. Isian yang tertulis dengan bintang (*) adalah isian wajib."),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                      labelText: 'Nama Kontak *', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    } else if (value.length <= 6) {
                      return 'Nama harus lebih dari 6 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _perusahaanController,
                  decoration: InputDecoration(
                      labelText: 'Nama Perusahaan',
                      border: OutlineInputBorder()),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _alamatController,
                  decoration: InputDecoration(
                      labelText: 'Alamat Lengkap *',
                      border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                ),
                SizedBox(
                  height: 20,
                ),
                DropdownSearch<String>(
                  items: _kota,
                  dropdownSearchDecoration: getInputDecoration().copyWith(
                    labelText: "Kota",
                    contentPadding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                  ),
                  validator: (value) =>
                      value == null ? "Kota harus diisi" : null,
                  showSearchBox: true,
                  onChanged: (value) {
                    setState(() {
                      selectedCity = _idkota[_kota.indexOf(value!)];
                    });
                    // print(value!.id);
                    // setState(() {
                    //   pilihMetPem = value!.id;
                    // });
                  },
                ),
                // DropdownButtonFormField(
                //   isExpanded: true,
                //   decoration: InputDecoration(
                //     labelText: 'Kota',
                //     border: OutlineInputBorder(),
                //   ),
                //   value: selectedCity,
                //   items: cities.map((city) {
                //     return DropdownMenuItem(
                //       value: city['id'],
                //       child: Text(city['nama_kota']),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       selectedCity = value as String?;
                //     });
                //   },
                // ),
                SizedBox(
                  height: 30,
                ),
                Text(
                    "Layanan pengiriman barang hanya dapat dilakukan untuk kota-kota yang tercantum pada daftar di atas. Jika lokasi Anda tidak tercantum, tuliskan nama kota Anda pada kota di bawah ini:"),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _kotalainController,
                  decoration: InputDecoration(
                      labelText: 'Kota Lain', border: OutlineInputBorder()),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _kodePosController,
                  keyboardType: TextInputType.text,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]')), // Allow only digits
                  ],
                  decoration: InputDecoration(
                      labelText: 'Kode Pos *', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      child: TextField(
                        controller: _notelpKodeNegaraController,
                        keyboardType: TextInputType.text,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]')), // Allow only digits
                        ],
                        decoration: InputDecoration(
                            hintText: "62",
                            labelText: 'Kode Negara',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    Container(
                      width: 120,
                      child: TextField(
                        controller: _notelpKodeDaerahController,
                        keyboardType: TextInputType.text,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]')), // Allow only digits
                        ],
                        decoration: InputDecoration(
                            hintText: "274",
                            labelText: 'Kode Daerah',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    Container(
                      width: 120,
                      child: TextField(
                        controller: _notelpController,
                        keyboardType: TextInputType.text,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]')), // Allow only digits
                        ],
                        decoration: InputDecoration(
                            labelText: 'Telepon', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nohpController,
                  keyboardType: TextInputType.text,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]')), // Allow only digits
                  ],
                  decoration: InputDecoration(
                    labelText: 'No. Seluler',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitForm,
                  child: Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
