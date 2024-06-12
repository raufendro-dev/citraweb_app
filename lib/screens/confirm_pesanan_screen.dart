import 'dart:convert';
import 'dart:io';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as Img;
import 'package:path/path.dart' as p;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/models/dropdown_model.dart';
import 'package:http/http.dart' as http;
import 'package:mikrotik/models/dropdown_model2.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:mime/mime.dart';

class ConfirmPesananScreen extends StatefulWidget {
  const ConfirmPesananScreen({Key? key}) : super(key: key);

  @override
  _ConfirmPesananScreenState createState() => _ConfirmPesananScreenState();
}

class _ConfirmPesananScreenState extends State<ConfirmPesananScreen> {
  final auth = AuthService();
  List<DropdownModel> listMetodePembayaran = [];

  Future<List<DropdownModel>> fetchMetodePembayaran() async {
    final List<DropdownModel> listMP = [];

    final responseJenisPerusahaan = await http.get(Uri.parse(Config.baseUrlApi +
        '/app-api/konfirmasi-pembayaran/metode-pembayaran/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        (await auth.idUser) +
        '&sess_id=' +
        (await auth.sessId)));
    print(Config.baseUrlApi +
        '/app-api/konfirmasi-pembayaran/metode-pembayaran/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        (await auth.idUser) +
        '&sess_id=' +
        (await auth.sessId));
    if (responseJenisPerusahaan.statusCode == 200) {
      print('fetchMetodePembayaran');
      final Map jenisPerusahaan = jsonDecode(responseJenisPerusahaan.body);
      if (jenisPerusahaan['data'].isNotEmpty) {
        for (var infoItem in jenisPerusahaan['data']) {
          listMetodePembayaran.add(
              DropdownModel(id: infoItem['value'], name: infoItem['nama']));
        }
      }
    } else {
      print('Failed to load metodePembayaran');
    }
    print(listMetodePembayaran);
    return listMetodePembayaran;
  }

  List<DropdownModel2> listNota = [];

  Future<List<DropdownModel2>> fetchNota() async {
    final List<DropdownModel2> listNot = [];

    final responseJenisPerusahaan = await http.get(Uri.parse(Config.baseUrlApi +
        '/app-api/konfirmasi-pembayaran/no-nota/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        (await auth.idUser) +
        '&sess_id=' +
        (await auth.sessId)));
    print(Config.baseUrlApi +
        '/app-api/konfirmasi-pembayaran/no-nota/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        (await auth.idUser) +
        '&sess_id=' +
        (await auth.sessId));
    if (responseJenisPerusahaan.statusCode == 200) {
      print('fetchMetodePembayaran');
      final Map jenisPerusahaan = jsonDecode(responseJenisPerusahaan.body);
      if (jenisPerusahaan['data'].isNotEmpty) {
        for (var infoItem in jenisPerusahaan['data']) {
          listNota.add(DropdownModel2(
              id: infoItem['value'],
              name: infoItem['nama'],
              total: infoItem['jumlah']));
        }
      }
    } else {
      print('Failed to load listNota');
    }
    print(listNota);
    return listNota;
  }

  final _MetodePembayaranKey = GlobalKey<DropdownSearchState<DropdownModel>>();
  final _NotaKey = GlobalKey<DropdownSearchState<DropdownModel>>();
  String fileName = '';
  String fileBase64 = '';
  String fileType = '';
  String alertFile = '';
  InputDecoration getInputDecoration() {
    return const InputDecoration(
      isDense: true,
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      border: OutlineInputBorder(),
    );
  }

  var pilihMetPem;
  var pilihNota;
  List<String> dates = List.generate(31, (index) => (index + 1).toString());
  List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  Map<String, String> monthMap = {
    'Januari': '01',
    'Februari': '02',
    'Maret': '03',
    'April': '04',
    'Mei': '05',
    'Juni': '06',
    'Juli': '07',
    'Agustus': '08',
    'September': '09',
    'Oktober': '10',
    'November': '11',
    'Desember': '12'
  };
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
                Text('Loading...'),
              ],
            ),
          ),
        );
      },
    );
  }

  String getValueForMonth(String selectedMonth) {
    return monthMap[selectedMonth] ??
        ''; // Handle non-existent months gracefully
  }

  List<String> years = List.generate(50, (index) => (index + 2022).toString());

  String selectedDate = '1';
  String selectedMonth = 'Januari';
  String selectedMonth2 = '';
  String selectedYear = '2022';
  var totalnya = "";
  var controllerJumlahPembayaran = TextEditingController();
  var controllerPesan = TextEditingController();
  var controllerLampiranTeks = TextEditingController();
  Future<Map<String, dynamic>> konfirmasi() async {
    var a;
    var b;
    if (controllerLampiranTeks.text.isEmpty) {
      a = "";
    } else {
      a = controllerLampiranTeks.text;
    }
    selectedMonth2 = getValueForMonth(selectedMonth);
    print(selectedMonth2);
    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "ip": await AuthService.getIPAddress(),
      "iduser": (await auth.idUser),
      "sess_id": (await auth.sessId),
      "no_nota": pilihNota,
      "total": totalnya,
      "metode_pembayaran": pilihMetPem,
      "tgl_pembayaran": selectedDate,
      "bln_pembayaran": selectedMonth2,
      "thn_pembayaran": selectedYear,
      "jumlah_bayar": controllerJumlahPembayaran.text,
      "pesan_ket": controllerPesan.text,
      "file_bukti": fileBase64,
      "file_name": fileName,
      "file_tipe": fileType.replaceAll(".", ""),
      "teks_bukti": a
    });
    print(bodyPost);
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/konfirmasi-pembayaran/'),
      body: bodyPost,
    );
    print(res.body);
    if (res.statusCode == 200) {
      print(jsonDecode(res.body)['data'].first);
      return jsonDecode(res.body)['data'].first;
    }
    return {"daftar": false, "msg": "Terjadi kesalahan saat pendaftaran"};
  }

  final _keyKonfirmasi = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchMetodePembayaran().then((value) {
      setState(() {
        listMetodePembayaran = value;
      });
    });
    fetchNota().then((value) {
      setState(() {
        listNota = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran Member'),
      ),
      body: SingleChildScrollView(
        child: Form(
            key: _keyKonfirmasi,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Konfirmasi Pembayaran',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Isilah form di bawah HANYA jika Anda telah melakukan pembayaran.\nJangan mengisi form di bawah ini jika Anda belum melakukan pembayaran.',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 25),
                  DropdownSearch<DropdownModel2>(
                    key: _NotaKey,
                    items: listNota,
                    dropdownSearchDecoration: getInputDecoration().copyWith(
                      labelText: "Nota",
                      contentPadding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                    ),
                    validator: (value) =>
                        value == null ? "Selahkan pilih Nota" : null,
                    showSearchBox: true,
                    onChanged: (value) {
                      print(value!.id);
                      setState(() {
                        pilihNota = value!.id;
                        print(value!.total);
                        totalnya = value!.total;
                      });
                    },
                  ),
                  totalnya != ""
                      ? Column(
                          children: [
                            const SizedBox(height: 12),
                            Text("Jumlah : Rp " + totalnya),
                          ],
                        )
                      : Container(),
                  const SizedBox(height: 15),
                  DropdownSearch<DropdownModel>(
                    key: _MetodePembayaranKey,
                    items: listMetodePembayaran,
                    dropdownSearchDecoration: getInputDecoration().copyWith(
                      labelText: "Metode Pembayaran",
                      contentPadding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                    ),
                    validator: (value) => value == null
                        ? "Selahkan pilih metode pembayaran"
                        : null,
                    showSearchBox: true,
                    onChanged: (value) {
                      print(value!.id);
                      setState(() {
                        pilihMetPem = value!.id;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text("Tanggal Pembayaran"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: selectedDate,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDate = newValue!;
                            });
                          },
                          items: dates
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: 20),
                        DropdownButton<String>(
                          value: selectedMonth,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMonth = newValue!;
                            });
                          },
                          items: months
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: 20),
                        DropdownButton<String>(
                          value: selectedYear,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedYear = newValue!;
                            });
                          },
                          items: years
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerJumlahPembayaran,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan jumlah pembayaran';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      hintText: '50000',
                      labelText: 'Jumlah Pembayaran',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerPesan,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan jumlah pembayaran';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      hintText: '',
                      labelText: 'Pesan',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Upload Bukti Pembayaran (Optional)"),
                  Column(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            final ImagePicker _picker = ImagePicker();
                            XFile? image;
                            image = await _picker.pickImage(
                                source: ImageSource.gallery);
                            print(image!.name);
                            print(image.path);
                            final extension = p.extension(image.path);
                            print(extension);
                            File file = File(image.path.toString());
                            var result =
                                await FlutterImageCompress.compressWithFile(
                              file.path,
                              minWidth: 800,
                              minHeight: 600,
                              quality: 70,
                            );
                            print(result);
                            // List<int> fileInByte = result.readAsBytesSync();
                            String fileInBase64 = base64Encode(result!);

                            String dataBase64 = ('data:' +
                                lookupMimeType(image.path).toString() +
                                ';base64,' +
                                fileInBase64);
                            print(dataBase64);
                            setState(() {
                              fileName = image!.name.toString();

                              fileBase64 = dataBase64;
                              fileType = extension.toString();
                              alertFile = '';
                            });

                            print(fileName);
                          },
                          child: Text(
                            fileBase64 != ''
                                ? 'Ubah Foto Bukti Pembayaran'
                                : 'Pilih Foto Bukti Pembayaran',
                            textAlign: TextAlign.center,
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Atau jika Anda menerima email konfirmasi dari transaksi online Anda, lampirkanlah copy-paste-nya pada kotak teks di bawah ini:",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: controllerLampiranTeks,
                    keyboardType: TextInputType.text,
                    decoration: getInputDecoration().copyWith(
                      hintText: '',
                      labelText: 'Lampiran Teks Bukti Pembayaran (optional)',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_keyKonfirmasi.currentState!.validate()) {
                          showLoadingDialog();
                          konfirmasi().then(
                            (value) {
                              print(value);
                              showDialog<void>(
                                context: context,
                                useRootNavigator: false,
                                barrierDismissible:
                                    false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Html(
                                      data: value['msg'],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        }
                      },
                      child: Text("Konfirmasi Pembayaran"),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              )),
            )),
      ),
    );
  }
}
