// ignore_for_file: avoid_print
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as Img;
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/services/auth_service.dart';
import '../models/dropdown_model.dart';

class FormRmaTanpa extends StatefulWidget {
  const FormRmaTanpa({Key? key}) : super(key: key);

  @override
  State<FormRmaTanpa> createState() => _FormRmaTanpaState();
}

class _FormRmaTanpaState extends State<FormRmaTanpa> {
  final controllerPerusahaan = TextEditingController();
  final controllerAlamatLengkap = TextEditingController();
  final controllerTelp = TextEditingController();
  final controllerFax = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerNama = TextEditingController();

  final controllerSerialNumber = TextEditingController();
  final controllerKeluhan = TextEditingController();
  final controllerKelengkapan = TextEditingController();
  final _jenisBarang = GlobalKey<DropdownSearchState<DropdownModel>>();
  final _detailProduk = GlobalKey<DropdownSearchState<DropdownModel>>();

  final _keyRma = GlobalKey<FormState>();

  String tambahRmaError = '';

  List<DropdownModel> listJenibarang = [];
  List<DropdownModel> listDetailProduk = [];
  List<Map<String, dynamic>>? listRmaSession = [];

  Future<Map<String, dynamic>> fetchProfile() async {
    Map<String, dynamic> profileObj = {};
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    final responseProfile = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/profil/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        dataLogin['MKid'] +
        '&sess_id=' +
        dataLogin['sess_id']));
    if (responseProfile.statusCode == 200) {
      print('fetchProfile');
      final Map profil = jsonDecode(responseProfile.body);
      if (profil['data'].isNotEmpty) {
        // for (var infoProfile in profil['data']) {
        //   // profileObj.add(infoProfile);

        // }
        profileObj = profil['data'].first;
      }
    } else {
      print('Failed to load Profile');
    }
    return profileObj;
  }

  Future<List<Map<String, dynamic>>> fetchRmaSession() async {
    List<Map<String, dynamic>> rmaSession = [];
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    final responseRmaSession = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/rma/cek-session/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        dataLogin['MKid'] +
        '&sess_id=' +
        dataLogin['sess_id']));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/rma/cek-session/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        dataLogin['MKid'] +
        '&sess_id=' +
        dataLogin['sess_id']));
    if (responseRmaSession.statusCode == 200) {
      print('fetchRmaSession');
      final Map listRmaSession = jsonDecode(responseRmaSession.body);
      if (listRmaSession['data'].first['ada_rma']) {
        for (var infoRma in listRmaSession['data'].first['data_rma']) {
          rmaSession.add(infoRma);
        }
        // rmaSession = profil['data'].first;
      }
    } else {
      print('Failed to load rma session');
    }
    return rmaSession;
  }

  // Future<List<DropdownModel>> fetchJenisBarang() async {
  //   final List<DropdownModel> listJenisBarang = [];

  //   var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

  //   var bodyPost = jsonEncode({
  //     "key": "0cc7da679bea04fea453c8062e06514d",
  //     "iduser": dataLogin['MKid'],
  //     "sess_id": dataLogin['sess_id'],
  //     "sn": controllerSerialNumber.text
  //   });

  //   final responseNoInvoice = await http.post(
  //     Uri.parse(Config.baseUrlApi + 'app-api/rma/serial-number/'),
  //     body: bodyPost,
  //   );

  //   if (responseNoInvoice.statusCode == 200) {
  //     print('fetchSerialNumber');

  //     final Map noInvoice = jsonDecode(responseNoInvoice.body);
  //     print(noInvoice);
  //     // if (noInvoice['data'].isNotEmpty) {
  //     //   var bodyPost = jsonEncode({
  //     //     "key": "0cc7da679bea04fea453c8062e06514d",
  //     //     "iduser": dataLogin['MKid'],
  //     //     "sess_id": dataLogin['sess_id'],
  //     //     "no_invoice_value": noInvoice['data'].first['noInvoice']
  //     //   });

  //     //   // print(bodyPost);
  //     //   final responseJenisBarang = await http.post(
  //     //     Uri.parse(Config.baseUrlApi + 'app-api/rma/jenis-barang/'),
  //     //     body: bodyPost,
  //     //   );

  //     //   final Map jenisBarang = jsonDecode(responseJenisBarang.body);
  //     //   if (jenisBarang['data'].isNotEmpty) {
  //     //     for (var infoItem in jenisBarang['data'].first['data_jenis_barang']) {
  //     //       infoItem['id_order'] = jenisBarang['data'].first['id_order'];
  //     //       listJenisBarang.add(DropdownModel(
  //     //         id: infoItem['jenis_barang_value'],
  //     //         name: infoItem['jenis_barang'],
  //     //         data: infoItem,
  //     //       ));
  //     //     }
  //     //     // print(jenisBarang['data']);
  //     //   }
  //     // }
  //   } else {
  //     print('Failed to load Serial Number');
  //   }
  //   return listJenisBarang;
  // }

  // Future<List<DropdownModel>> fetchDetailProduk() async {
  //   final List<DropdownModel> listDetailProduk = [];

  //   var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

  //   var bodyPost = jsonEncode({
  //     "key": "0cc7da679bea04fea453c8062e06514d",
  //     "iduser": dataLogin['MKid'],
  //     "sess_id": dataLogin['sess_id'],
  //     "jenis_barang_value": _jenisBarang.currentState!.getSelectedItem!.id
  //   });

  //   final responseDetailProduk = await http.post(
  //     Uri.parse(Config.baseUrlApi + 'app-api/rma/detail-produk/'),
  //     body: bodyPost,
  //   );

  //   if (responseDetailProduk.statusCode == 200) {
  //     print('fetchSerialNumber');

  //     final Map detailProduk = jsonDecode(responseDetailProduk.body);
  //     if (detailProduk['data'].isNotEmpty) {
  //       if (detailProduk['data'].first['ada_detail_produk']) {
  //         for (var infoItem
  //             in detailProduk['data'].first['data_detail_produk']) {
  //           listDetailProduk.add(DropdownModel(
  //             id: infoItem['detail_id'],
  //             name: infoItem['detail_produk_value'],
  //             data: infoItem,
  //           ));
  //         }
  //       }
  //       // print(jenisBarang['data']);
  //     }
  //   } else {
  //     print('Failed to load Serial Number');
  //   }
  //   return listDetailProduk;
  // }

  Future<Map<String, dynamic>> addProduk() async {
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "iduser": dataLogin['MKid'],
      "sess_id": dataLogin['sess_id'],
      "jenisBrg": _selectedItem,
      "noInvoice": "",
      "idtborder": "",
      "iddetail": "",
      "namaBarang": _namaDropDown,
      "type": "",
      "text": "",
      "tglOrder": "",
      "keluhan": controllerKeluhan.text,
      "kelengkapan": controllerKelengkapan.text,
      "image_base64": fileBase64,
      "tipefile": fileType.replaceAll(".", ""),
    });
    print(bodyPost);
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/rma/add-session-no-lisensi/'),
      body: bodyPost,
    );
    print(res.body);
    if (res.statusCode == 200) {
      print(jsonDecode(res.body)['data'].first);
      return jsonDecode(res.body)['data'].first;
    }
    return {"add_sukses": false, "data_rma": []};
  }

  Future<List<Map<String, dynamic>>> hapusSession(dynamic id) async {
    List<Map<String, dynamic>> delSession = [];
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    final responseDelSession = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/rma/delete-session/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        dataLogin['MKid'] +
        '&sess_id=' +
        dataLogin['sess_id'] +
        '&id=$id'));
    if (responseDelSession.statusCode == 200) {
      print('hapusSession');
      final Map listDelSession = jsonDecode(responseDelSession.body);
      if (listDelSession['data'].isNotEmpty) {
        for (var infoRma in listDelSession['data']) {
          delSession.add(infoRma);
        }
        // delSession = profil['data'].first;
      }
    } else {
      print('Failed to del session');
    }
    return delSession;
  }

  Future<List<Map<String, dynamic>>> kirimRma() async {
    List<Map<String, dynamic>> listKirimRma = [];
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "iduser": dataLogin['MKid'],
      "sess_id": dataLogin['sess_id'],
    });

    final responseKirimSession = await http.post(
        Uri.parse(Config.baseUrlApi + 'app-api/rma/kirim-rma-no-lisensi/'),
        body: bodyPost);
    if (responseKirimSession.statusCode == 200) {
      print('hapusSession');
      final Map listKirimSession = jsonDecode(responseKirimSession.body);
      if (listKirimSession['data'].isNotEmpty) {
        for (var infoKirim in listKirimSession['data']) {
          listKirimRma.add(infoKirim);
        }
        // listKirimRma = profil['data'].first;
      }
    } else {
      print('Failed to kirim RMA');
    }
    return listKirimRma;
  }

  InputDecoration inputKotak = const InputDecoration(
    isDense: true,
    enabledBorder: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(),
    border: OutlineInputBorder(),
  );

  @override
  void initState() {
    super.initState();
    fetchProfile().then((value) {
      setState(() {
        controllerPerusahaan.text = value['perusahaan'];
        controllerAlamatLengkap.text = value['alamat'];
        controllerTelp.text = value['telp'];
        controllerFax.text = value['fax'];
        controllerEmail.text = value['email'];
        controllerNama.text = value['nama'];
      });
    });
    fetchRmaSession().then((value) {
      setState(() {
        listRmaSession = value;
      });
    });
    ambilDropDown();
    print(listRmaSession);
  }

  List<DropdownMenuItem<String>> _dropdownMenuItems = [];
  Map datadropdown = {};
  String _selectedItem = '';
  String _namaDropDown = '';
  String fileName = '';
  String fileBase64 = '';
  String fileType = '';
  String alertFile = '';
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

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Prevent user from dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Center content horizontally
              children: [
                Text('Sukses Menambahkan Data'),
              ],
            ),
          ),
        );
      },
    );
  }

  ambilDropDown() async {
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    final response = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/rma/jenis-produk/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        dataLogin['MKid'] +
        '&sess_id=' +
        dataLogin['sess_id']));
    final Map data = jsonDecode(response.body);
    print(data['data']);
    for (var i = 0; i < data['data'].length; i++) {
      _dropdownMenuItems.add(DropdownMenuItem(
        value: data['data'][i]['id'],
        child: Text(data['data'][i]['nama']),
      ));
      datadropdown[data['data'][i]['id']] = data['data'][i]['nama'];
    }
    setState(() {
      _selectedItem = data['data'][0]['id'];
    });
    print(datadropdown);
  }

  void _onSelectedItemChanged(String? newValue) {
    setState(() {
      _selectedItem = newValue.toString();
      _namaDropDown = datadropdown[_selectedItem];
    });
    print(_namaDropDown);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan RMA Tanpa Serial'),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Data Kontak',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: false,
                controller: controllerPerusahaan,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Silahkan masukan nama perusahaan';
                  }
                  return null;
                },
                decoration: inputKotak.copyWith(
                  prefixIcon: const Icon(
                    FontAwesomeIcons.building,
                    size: 20,
                  ),
                  hintText: 'Citraweb',
                  labelText: 'Perusahaan',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                enabled: false,
                controller: controllerAlamatLengkap,
                keyboardType: TextInputType.streetAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Silahkan masukan alamat lengkap';
                  }
                  return null;
                },
                maxLines: 3,
                decoration: inputKotak.copyWith(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  prefixIcon: const Icon(
                    FontAwesomeIcons.mapMarkedAlt,
                    size: 20,
                  ),
                  hintText: 'Jalan Petung 31 Papringan Yogyakarta',
                  labelText: 'Alamat Lengkap',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                enabled: false,
                controller: controllerTelp,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Silahkan masukan no selular';
                  }
                  return null;
                },
                decoration: inputKotak.copyWith(
                  prefixIcon: const Icon(
                    FontAwesomeIcons.phoneAlt,
                    size: 20,
                  ),
                  hintText: '62-274-XXXXXX',
                  labelText: 'Telp',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                enabled: false,
                controller: controllerFax,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Silahkan masukan no fax';
                  }
                  return null;
                },
                decoration: inputKotak.copyWith(
                  prefixIcon: const Icon(
                    FontAwesomeIcons.fax,
                    size: 20,
                  ),
                  hintText: '62-274-XXXXXX',
                  labelText: 'Fax',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                enabled: false,
                controller: controllerEmail,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Silahkan masukan alamat email';
                  }
                  return null;
                },
                decoration: inputKotak.copyWith(
                  prefixIcon: const Icon(
                    FontAwesomeIcons.envelope,
                    size: 20,
                  ),
                  hintText: 'you@example.com',
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                enabled: false,
                controller: controllerNama,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Silahkan masukan nama lengkap min 6 karakter';
                  }
                  return null;
                },
                decoration: inputKotak.copyWith(
                  prefixIcon: const Icon(
                    FontAwesomeIcons.user,
                    size: 20,
                  ),
                  hintText: 'John Wick',
                  labelText: 'Kontak Person',
                ),
              ),
              const SizedBox(height: 12),

              const Divider(thickness: 1),
              const SizedBox(height: 12),

              Text(
                'Produk',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedItem,
                items: _dropdownMenuItems,
                onChanged: _onSelectedItemChanged,
                decoration: inputKotak,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controllerKeluhan,
                keyboardType: TextInputType.text,
                maxLines: 6,
                decoration: inputKotak.copyWith(
                  hintText: 'Silahkan masukan keluhan anda',
                  labelText: 'Keluhan',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controllerKelengkapan,
                keyboardType: TextInputType.text,
                maxLines: 6,
                decoration: inputKotak.copyWith(
                  hintText: 'Masukan Kelengkapan',
                  labelText: 'Kelengkapan',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Foto Segel Garansi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                  onPressed: () async {
                    final ImagePicker _picker = ImagePicker();
                    XFile? image;
                    image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    print(image!.name);
                    print(image.path);
                    final extension = p.extension(image.path);
                    print(extension);
                    File file = File(image.path.toString());
                    var result = await FlutterImageCompress.compressWithFile(
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

                    print(fileType);
                  },
                  child: Text(
                    fileBase64 != ''
                        ? 'Ubah Foto Segel'
                        : 'Pilih Foto Segel Garansi',
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          if (controllerKeluhan.text.isNotEmpty &&
                              controllerKelengkapan.text.isNotEmpty &&
                              fileBase64 != '') {
                            showLoadingDialog();
                            print(listRmaSession);
                            await addProduk();
                            fetchRmaSession().then((value) {
                              setState(() {
                                listRmaSession = value;
                              });
                              controllerKeluhan.clear();
                              controllerKelengkapan.clear();
                              setState(() {
                                fileBase64 = '';
                              });
                              Navigator.pop(context);
                              showSuccessDialog();
                            });
                          }
                        },
                        child: Text("Tambah Pengajuan")),
                    ElevatedButton(
                        onPressed: listRmaSession!.isNotEmpty
                            ? () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          const FormRmaTanpaK(),
                                    ));
                              }
                            : null,
                        child: Text("Kirim Data")),
                  ],
                ),
              )
              // const SizedBox(height: 12),
              // ...listRmaSession!
              //     .map((e) => Column(
              //           children: [
              //             Row(
              //               children: [
              //                 Expanded(
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       Text(e['nama']),
              //                       Text('Keluhan: ' + e['keluhan']),
              //                       Text('Kelengkapan: ' + e['kelengkapan']),
              //                     ],
              //                   ),
              //                 ),
              //                 SizedBox(
              //                   width: 40,
              //                   height: 40,
              //                   child: IconButton(
              //                     onPressed: () {
              //                       print('hapus rma session');
              //                       hapusSession(e['id']).then((value) {
              //                         if (value.first['hapus_session']) {
              //                           fetchRmaSession().then((value) {
              //                             setState(() {
              //                               listRmaSession = value;
              //                             });
              //                           });
              //                         }
              //                       });
              //                     },
              //                     splashRadius: 24,
              //                     icon: const Icon(
              //                       Icons.delete,
              //                       color: Colors.grey,
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //             const Divider(),
              //           ],
              //         ))
              //     .toList(),
              // // const SizedBox(height: 12),
              // SizedBox(
              //   height: 30,
              //   child: TextButton.icon(
              //     style: TextButton.styleFrom(padding: const EdgeInsets.all(4)),
              //     onPressed: () {
              //       // showModalBottomSheet(
              //       //   context: context,
              //       //   isScrollControlled: true,
              //       //   builder: (context) => cariRma(context),
              //       // ).then((value) {
              //       //   setState(() {
              //       //     // controllerSerialNumber.text = '';
              //       //     controllerKeluhan.text = '';
              //       //     controllerKelengkapan.text = '';
              //       //     listJenibarang = [];
              //       //     listDetailProduk = [];
              //       //     tambahRmaError = '';
              //       //   });
              //       //   if (value) {
              //       //     fetchRmaSession().then((value) {
              //       //       setState(() {
              //       //         listRmaSession = value;
              //       //       });
              //       //     });
              //       //   }
              //       // });
              //     },
              //     icon: const Icon(Icons.add),
              //     label: const Text('Tambah Produk'),
              //   ),
              // ),
              // const Divider(thickness: 1),
              // if (listRmaSession!.isNotEmpty)
              //   Container(
              //     width: double.infinity,
              //     alignment: Alignment.center,
              //     child: ElevatedButton(
              //       onPressed: () {
              //         kirimRma().then((value) {
              //           print(value);
              //           if (value.first['ada_rma']) {
              //             Fluttertoast.showToast(
              //                 msg: 'RMA berhasil dikirim',
              //                 toastLength: Toast.LENGTH_LONG,
              //                 gravity: ToastGravity.CENTER,
              //                 backgroundColor: Colors.black.withOpacity(0.7));
              //             Navigator.pop(context, true);
              //           }
              //         });
              //       },
              //       child: const Text('Kirim RMA'),
              //     ),
              //   ),
              // const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // cariRma(BuildContext context) => StatefulBuilder(
  //       builder: (context, setState) => Padding(
  //         padding: EdgeInsets.fromLTRB(
  //             8, 8, 8, MediaQuery.of(context).viewInsets.bottom),
  //         child: Form(
  //           key: _keyRma,
  //           child: Wrap(
  //             alignment: WrapAlignment.center,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(vertical: 12.0),
  //                 child: Text(
  //                   'Tambah Produk RMA',
  //                   style: Theme.of(context).textTheme.bodyText1,
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(bottom: 12.0),
  //                 child: TextFormField(
  //                   controller: controllerSerialNumber,
  //                   keyboardType: TextInputType.name,
  //                   textInputAction: TextInputAction.search,
  //                   validator: (value) {
  //                     if (value!.isEmpty || value.length < 6) {
  //                       return 'Silahkan masukan serial number';
  //                     }
  //                     return null;
  //                   },
  //                   decoration: getInputDecoration().copyWith(
  //                     // prefixIcon: const Icon(FontAwesomeIcons.barcode),
  //                     suffixIcon: IconButton(
  //                       icon: const Icon(Icons.search),
  //                       onPressed: () {
  //                         print('search serial number');
  //                         FocusManager.instance.primaryFocus?.unfocus();
  //                         fetchJenisBarang().then((value) {
  //                           setState(() {
  //                             listJenibarang = value;
  //                             tambahRmaError = value.isEmpty
  //                                 ? 'Serial number tidak ditemukan'
  //                                 : '';
  //                           });
  //                         });
  //                       },
  //                       splashRadius: 24,
  //                     ),
  //                     hintText: 'xxxx-xxxx-xxxx-xxxx',
  //                     labelText: 'Serial Number',
  //                   ),
  //                   onFieldSubmitted: (value) {
  //                     print('search serial number');
  //                     fetchJenisBarang().then((value) {
  //                       setState(() {
  //                         listJenibarang = value;
  //                         tambahRmaError = value.isEmpty
  //                             ? 'Serial number tidak ditemukan'
  //                             : '';
  //                       });
  //                     });
  //                   },
  //                 ),
  //               ),
  //               if (listJenibarang.isNotEmpty)
  //                 Padding(
  //                   padding: const EdgeInsets.only(bottom: 12.0),
  //                   child: DropdownSearch<DropdownModel>(
  //                     key: _jenisBarang,
  //                     onChanged: (value) {
  //                       print(_jenisBarang.currentState!.getSelectedItem!.id);
  //                       fetchDetailProduk().then((value) {
  //                         print(value);
  //                         setState(() {
  //                           listDetailProduk = value;
  //                           tambahRmaError = value.isEmpty
  //                               ? 'Detail Produk tidak ditemukan'
  //                               : '';
  //                         });
  //                       });
  //                     },
  //                     items: listJenibarang,
  //                     dropdownSearchDecoration: getInputDecoration().copyWith(
  //                       // prefixIcon: const Icon(FontAwesomeIcons.building),
  //                       labelText: "Jenis Barang",
  //                       contentPadding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
  //                     ),
  //                     validator: (value) =>
  //                         value == null ? "Selahkan pilih jenis barang" : null,
  //                     showSearchBox: true,
  //                   ),
  //                 ),
  //               if (listDetailProduk.isNotEmpty)
  //                 Padding(
  //                   padding: const EdgeInsets.only(bottom: 12.0),
  //                   child: DropdownSearch<DropdownModel>(
  //                     key: _detailProduk,
  //                     items: listDetailProduk,
  //                     dropdownSearchDecoration: getInputDecoration().copyWith(
  //                       // prefixIcon: const Icon(FontAwesomeIcons.building),
  //                       labelText: "Detail Produk",
  //                       contentPadding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
  //                     ),
  //                     validator: (value) =>
  //                         value == null ? "Selahkan pilih detail produk" : null,
  //                     showSearchBox: true,
  //                   ),
  //                 ),
  //               if (listDetailProduk.isNotEmpty)
  //                 Padding(
  //                   padding: const EdgeInsets.only(bottom: 12.0),
  //                   child: TextFormField(
  //                     controller: controllerKeluhan,
  //                     keyboardType: TextInputType.streetAddress,
  //                     validator: (value) {
  //                       if (value!.isEmpty) {
  //                         return 'Silahkan masukan keluhan produk';
  //                       }
  //                       return null;
  //                     },
  //                     maxLines: 3,
  //                     decoration: getInputDecoration().copyWith(
  //                       contentPadding: const EdgeInsets.symmetric(
  //                         vertical: 14,
  //                         horizontal: 12,
  //                       ),
  //                       // prefixIcon: const Icon(FontAwesomeIcons.mapMarkedAlt),
  //                       hintText: 'Keluhan',
  //                       labelText: 'Keluhan',
  //                     ),
  //                   ),
  //                 ),
  //               if (listDetailProduk.isNotEmpty)
  //                 TextFormField(
  //                   controller: controllerKelengkapan,
  //                   keyboardType: TextInputType.streetAddress,
  //                   validator: (value) {
  //                     if (value!.isEmpty) {
  //                       return 'Silahkan masukan kelengkapan produk';
  //                     }
  //                     return null;
  //                   },
  //                   maxLines: 3,
  //                   decoration: getInputDecoration().copyWith(
  //                     contentPadding: const EdgeInsets.symmetric(
  //                       vertical: 14,
  //                       horizontal: 12,
  //                     ),
  //                     // prefixIcon: const Icon(FontAwesomeIcons.mapMarkedAlt),
  //                     hintText: 'Kelengkapan Produk',
  //                     labelText: 'Kelengkapan Produk',
  //                   ),
  //                 ),
  //               if (listDetailProduk.isNotEmpty)
  //                 ElevatedButton(
  //                     onPressed: () {
  //                       FocusScope.of(context).unfocus();
  //                       if (_keyRma.currentState!.validate()) {
  //                         addProduk().then((value) {
  //                           if (value['add_sukses']) {
  //                             _keyRma.currentState!.reset();
  //                             controllerSerialNumber.text = '';
  //                             Navigator.of(context).pop(true);
  //                           }
  //                         });
  //                       }
  //                     },
  //                     child: const Text('Tambahkan')),
  //               if (tambahRmaError.isNotEmpty)
  //                 Container(
  //                   width: double.infinity,
  //                   height: 40,
  //                   alignment: Alignment.center,
  //                   child: Text(tambahRmaError),
  //                 ),
  //               const SizedBox(height: 80),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );

  InputDecoration getInputDecoration() {
    return const InputDecoration(
      isDense: true,
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      border: OutlineInputBorder(),
    );
  }
}

class FormRmaTanpaK extends StatefulWidget {
  const FormRmaTanpaK({Key? key}) : super(key: key);

  @override
  _FormRmaTanpakState createState() => _FormRmaTanpakState();
}

class _FormRmaTanpakState extends State<FormRmaTanpaK> {
  late Future<List<Map<String, dynamic>>>? futureListRMA = fetchRMA();
  bool bolehKirim = false;
  Future<List<Map<String, dynamic>>> fetchRMA() async {
    List<Map<String, dynamic>> rmaSession = [];
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    final responseRmaSession = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/rma/cek-session/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        dataLogin['MKid'] +
        '&sess_id=' +
        dataLogin['sess_id']));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/rma/cek-session/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        dataLogin['MKid'] +
        '&sess_id=' +
        dataLogin['sess_id']));
    if (responseRmaSession.statusCode == 200) {
      print('fetchRmaSession');
      final Map listRmaSession = jsonDecode(responseRmaSession.body);
      if (listRmaSession['data'].first['ada_rma']) {
        for (var infoRma in listRmaSession['data'].first['data_rma']) {
          rmaSession.add(infoRma);
        }
        setState(() {
          bolehKirim = true;
        });
        // rmaSession = profil['data'].first;
      } else {
        setState(() {
          bolehKirim = false;
        });
      }
    } else {
      print('Failed to load rma session');
    }

    // print(listProduk);
    return rmaSession;
  }

  Future<List<Map<String, dynamic>>> hapusSession(dynamic id) async {
    List<Map<String, dynamic>> delSession = [];
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    final responseDelSession = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/rma/delete-session/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        dataLogin['MKid'] +
        '&sess_id=' +
        dataLogin['sess_id'] +
        '&id=$id'));
    if (responseDelSession.statusCode == 200) {
      print('hapusSession');
      final Map listDelSession = jsonDecode(responseDelSession.body);
      if (listDelSession['data'].isNotEmpty) {
        for (var infoRma in listDelSession['data']) {
          delSession.add(infoRma);
        }
        // delSession = profil['data'].first;
      }
    } else {
      print('Failed to del session');
    }
    return delSession;
  }

  Future<Map<String, dynamic>> kirimRMA() async {
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "iduser": dataLogin['MKid'],
      "sess_id": dataLogin['sess_id'],
    });
    print(bodyPost);
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/rma/kirim-rma-no-lisensi/'),
      body: bodyPost,
    );
    print(res.body);
    var hasil = jsonDecode(res.body);
    if (res.statusCode == 200) {}
    return hasil;
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
                Text('Loading...'),
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
        title: const Text('Kirim Pengajuan RMA'),
        titleSpacing: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureListRMA,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length != 0) {
                print(snapshot.data!.length);
                return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                          height: 0,
                          color: Colors.grey[200],
                          indent: 12,
                          endIndent: 12,
                          thickness: 1,
                        ),
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        color: Theme.of(context).colorScheme.background,
                        padding: const EdgeInsets.all(12),
                        // margin: const EdgeInsets.only(bottom: 12),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  snapshot.data![index]['nama'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                    onPressed: () async {
                                      await hapusSession(
                                              snapshot.data![index]['id'])
                                          .then((value) {
                                        setState(() {
                                          futureListRMA = fetchRMA();
                                        });
                                      });
                                    },
                                    child: Text("Hapus"))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Tanggal : " +
                                snapshot.data![index]['tgl_session_RMA']),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Keluhan : \n" +
                                snapshot.data![index]['keluhan']),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Kelengkapan : \n" +
                                snapshot.data![index]['kelengkapan']),
                            SizedBox(
                              height: 10,
                            ),
                            Image.memory(base64Decode(snapshot.data![index]
                                    ['image_base64']
                                .toString()
                                .replaceAll("data:image/jpeg;base64,", "")))
                          ],
                        ),
                      );
                    });
              } else {
                return Center(child: Text("Tidak ada data"));
              }
            } else {
              return Center(child: Text("Tidak ada data"));
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
          // icon: FaIcon(FontAwesomeIcons.whatsapp),
          label: Text("Kirim Pengajuan"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: bolehKirim == true
              ? () async {
                  print("Boleh kirim");
                  showLoadingDialog();
                  await kirimRMA().then((value) {
                    Navigator.pop(context);
                    setState(() {
                      futureListRMA = fetchRMA();
                    });
                  });
                }
              : null),
    );
  }
}
