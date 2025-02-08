import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/services/auth_service.dart';

class EditAddressFormScreen extends StatefulWidget {
  final int idal;
  EditAddressFormScreen({required this.idal});

  @override
  _EditAddressFormScreenState createState() => _EditAddressFormScreenState();
}

class _EditAddressFormScreenState extends State<EditAddressFormScreen> {
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
  List<String> _kota = [];
  List<String> _idkota = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  InputDecoration getInputDecoration() {
    return const InputDecoration(
      isDense: true,
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      border: OutlineInputBorder(),
    );
  }

  Future<void> loadData() async {
    await fetchCities();
    await fetchAlamatDetail(widget.idal);
  }

  Future<void> fetchCities() async {
    final response = await http.get(Uri.parse(Config.baseUrlApi +
        '/app-api/kota/?key=0cc7da679bea04fea453c8062e06514d'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey("data") && responseData["data"] is List) {
        setState(() {
          cities = List<Map<String, dynamic>>.from(responseData["data"]);
          _kota = cities.map((city) => city['nama_kota'].toString()).toList();
          _idkota = cities.map((city) => city['id'].toString()).toList();
        });
      }
    }
  }

  Future<void> fetchAlamatDetail(int idal) async {
    String id = await AuthService().idUser;
    String sessionI = await AuthService().sessId;
    final String url =
        "https://mkt.citraweb.co.id/app-api/keranjang/alamat-tujuan-detail/"
        "?key=0cc7da679bea04fea453c8062e06514d"
        "&iduser=$id"
        "&sess_id=$sessionI"
        "&id=$idal";

    print('AsW $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('Abc $data[0]');
        _notelpKodeNegaraController.text =
            data['data'][0]['kode_telp_negara'] ?? "";
        _notelpKodeDaerahController.text =
            data['data'][0]['kode_telp_daerah'] ?? "";
        _notelpController.text = data['data'][0]['notelp'] ?? "";
        _nohpController.text = data['data'][0]['nohp'] ?? "";

        setState(() {
          _namaController.text = data['data'][0]['nama'] ?? "";
          _perusahaanController.text = data['data'][0]['perusahaan'] ?? "";
          _alamatController.text = data['data'][0]['alamat'] ?? "";
          _kodePosController.text = data['data'][0]['kodepos'] ?? "";

          _kotalainController.text = data['data'][0]['kota_lain'] ?? "";

          // Set selected city
          String? kotaId = data['data'][0]['kota_id']?.toString();
          print("Jkkk $kotaId");
          // int index = _idkota.indexOf(kotaId.toString());
          selectedCity =
              selectedCity = _kota[_idkota.indexOf(kotaId.toString())];
          ;
          print("Kotaxx $selectedCity");
          if (kotaId != null && _idkota.contains(kotaId)) {
            // Use city name instead of ID
          }
        });
      } else {
        print("Gagal mengambil data. Kode: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    showLoadingDialog();

    String id = await AuthService().idUser;
    String sessionI = await AuthService().sessId;
    String ip = await AuthService.getIPAddress();

    final url =
        Uri.parse(Config.baseUrlApi + '/app-api/keranjang/alamat-tujuan-ubah/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "key": "0cc7da679bea04fea453c8062e06514d",
        "id": widget.idal,
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

    Navigator.pop(context);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      print('Failed to submit form');
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text('Menyimpan alamat...'),
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
                  selectedItem: selectedCity, // Ensure this is the city name
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
