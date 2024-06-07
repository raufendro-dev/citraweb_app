// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:mikrotik/services/auth_service.dart';
import '../models/dropdown_model.dart';

class RegisterPersonalScreen extends StatefulWidget {
  const RegisterPersonalScreen({Key? key}) : super(key: key);

  @override
  State<RegisterPersonalScreen> createState() => _RegisterPersonalScreenState();
}

class _RegisterPersonalScreenState extends State<RegisterPersonalScreen> {
  final _keyDaftar = GlobalKey<FormState>();

  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerUlangiPassword = TextEditingController();
  final controllerNama = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerSelular = TextEditingController();
  final controllerPerusahaan = TextEditingController();
  final controllerJabatan = TextEditingController();
  final controllerAlamatLengkap = TextEditingController();
  final controllerKotaLain = TextEditingController();
  final controllerKodePos = TextEditingController();
  final controllerTelpNegara = TextEditingController();
  final controllerTelpDaerah = TextEditingController();
  final controllerTelp = TextEditingController();
  final controllerFaxNegara = TextEditingController();
  final controllerFaxDaerah = TextEditingController();
  final controllerFax = TextEditingController();
  final controllerUrl = TextEditingController();
  final controllerNIK = TextEditingController();

  // final _jenisPerusahaanKey = GlobalKey<DropdownSearchState<DropdownModel>>();
  final _kotaKey = GlobalKey<DropdownSearchState<DropdownModel>>();

  bool showPassword = false;
  bool showUlangiPassword = false;

  final authService = AuthService();

  InputDecoration getInputDecoration() {
    return const InputDecoration(
      isDense: true,
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      border: OutlineInputBorder(),
    );
  }

  List<DropdownModel> listJenisPerusahaan = [];

  Future<List<DropdownModel>> fetchJenisPerusahaan() async {
    final List<DropdownModel> listJenisPerusahaan = [];

    final responseJenisPerusahaan = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/jenisperusahaan/?key=0cc7da679bea04fea453c8062e06514d'));
    if (responseJenisPerusahaan.statusCode == 200) {
      print('fetchJenisPerusahaan');
      final Map jenisPerusahaan = jsonDecode(responseJenisPerusahaan.body);
      if (jenisPerusahaan['data'].isNotEmpty) {
        for (var infoItem in jenisPerusahaan['data']) {
          listJenisPerusahaan.add(
              DropdownModel(id: infoItem['id'], name: infoItem['nama_jenis']));
        }
      }
    } else {
      print('Failed to load jenisPerusahaan');
    }
    return listJenisPerusahaan;
  }

  List<DropdownModel> listKota = [];

  Future<List<DropdownModel>> fetchKota() async {
    final List<DropdownModel> listKota = [];

    final responseKota = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/kota/?key=0cc7da679bea04fea453c8062e06514d'));
    if (responseKota.statusCode == 200) {
      print('fetchKota');
      final Map kota = jsonDecode(responseKota.body);
      if (kota['data'].isNotEmpty) {
        for (var infoItem in kota['data']) {
          listKota.add(
              DropdownModel(id: infoItem['id'], name: infoItem['nama_kota']));
        }
      }
    } else {
      print('Failed to load kota');
    }
    return listKota;
  }

  Future<Map<String, dynamic>> daftar() async {
    print("jalan DAFTAR");
    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "tipe_akun": "1",
      "ip": await AuthService.getIPAddress(),
      "userid": controllerUsername.text,
      "password": controllerPassword.text,
      "password2": controllerUlangiPassword.text,
      "nama": controllerNama.text,
      "email": controllerEmail.text,
      "selular": controllerSelular.text,
      "alamat": controllerAlamatLengkap.text,
      "kode_kota": _kotaKey.currentState!.getSelectedItem!.id,
      "kota_lain": controllerKotaLain.text,
      "kodepos": controllerKodePos.text,
      "nik": controllerNIK.text
    });
    print(bodyPost);
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/daftar/personal'),
      body: bodyPost,
    );
    print(res.body);
    if (res.statusCode == 200) {
      print(jsonDecode(res.body)['data'].first);
      return jsonDecode(res.body)['data'].first;
    }
    return {"daftar": false, "msg": "Terjadi kesalahan saat pendaftaran"};
  }

  @override
  void initState() {
    super.initState();

    fetchKota().then((value) {
      setState(() {
        listKota = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran Personal'),
      ),
      body: SingleChildScrollView(
        child:

            //     Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       print("cukk");
            //     },
            //     child: Text("tess"),
            //   ),
            // )

            Form(
          key: _keyDaftar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Data Login',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerUsername,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan masukan username';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.user),
                      hintText: 'johnwick',
                      labelText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerPassword,
                    obscureText: showPassword,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 8) {
                        return 'Silahkan masukan password min 8 karakter';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(Icons.vpn_key),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: showPassword
                            ? const Icon(
                                FontAwesomeIcons.eyeSlash,
                                size: 20,
                              )
                            : const Icon(
                                FontAwesomeIcons.eye,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerUlangiPassword,
                    obscureText: showUlangiPassword,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value!.isEmpty || value != controllerPassword.text) {
                        return 'Silahkan ulangi password';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(Icons.vpn_key),
                      labelText: 'Ulangi Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showUlangiPassword = !showUlangiPassword;
                          });
                        },
                        icon: showUlangiPassword
                            ? const Icon(
                                FontAwesomeIcons.eyeSlash,
                                size: 20,
                              )
                            : const Icon(
                                FontAwesomeIcons.eye,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Data Diri',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerNama,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Silahkan masukan nama lengkap min 6 karakter';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.user),
                      hintText: 'John Wick',
                      labelText: 'Nama Lengkap',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerNIK,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Silahkan masukan NIK lengkap min 16 karakter';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.user),
                      hintText: '917100000000000',
                      labelText: 'NIK',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Silahkan masukan alamat email';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.envelope),
                      hintText: 'you@example.com',
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerSelular,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan masukan no selular';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.mobileAlt),
                      hintText: '08123456789',
                      labelText: 'Selular',
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // TextFormField(
                  //   controller: controllerPerusahaan,
                  //   keyboardType: TextInputType.text,
                  //   validator: (value) {
                  //     if (value!.isEmpty) {
                  //       return 'Silahkan masukan nama perusahaan';
                  //     }
                  //     return null;
                  //   },
                  //   decoration: getInputDecoration().copyWith(
                  //     prefixIcon: const Icon(FontAwesomeIcons.building),
                  //     hintText: 'Citraweb',
                  //     labelText: 'Perusahaan',
                  //   ),
                  // ),
                  // const SizedBox(height: 12),
                  // DropdownSearch<DropdownModel>(
                  //   key: _jenisPerusahaanKey,
                  //   items: listJenisPerusahaan,
                  //   dropdownSearchDecoration: getInputDecoration().copyWith(
                  //     prefixIcon: const Icon(FontAwesomeIcons.building),
                  //     labelText: "Jenis Perusahaan",
                  //     contentPadding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                  //   ),
                  //   validator: (value) => value == null
                  //       ? "Selahkan pilih jenis perusahaan"
                  //       : null,
                  //   showSearchBox: true,
                  // ),
                  // const SizedBox(height: 12),
                  // TextFormField(
                  //   controller: controllerJabatan,
                  //   keyboardType: TextInputType.text,
                  //   validator: (value) {
                  //     if (value!.isEmpty) {
                  //       return 'Silahkan masukan jabatan';
                  //     }
                  //     return null;
                  //   },
                  //   decoration: getInputDecoration().copyWith(
                  //     prefixIcon: const Icon(FontAwesomeIcons.building),
                  //     hintText: 'Karyawan',
                  //     labelText: 'Jabatan',
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerAlamatLengkap,
                    keyboardType: TextInputType.streetAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan masukan alamat lengkap';
                      }
                      return null;
                    },
                    maxLines: 3,
                    decoration: getInputDecoration().copyWith(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 8,
                      ),
                      prefixIcon: const Icon(FontAwesomeIcons.mapMarkedAlt),
                      hintText: 'Jalan Petung 31 Papringan Yogyakarta',
                      labelText: 'Alamat Lengkap',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownSearch<DropdownModel>(
                    key: _kotaKey,
                    items: listKota,
                    // maxHeight: 300,
                    // onFind: (String? filter) => getData(filter),
                    dropdownSearchDecoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.mapMarkerAlt),
                      labelText: "Kota",
                      contentPadding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                      // border: OutlineInputBorder(),
                    ),
                    // onChanged: print,
                    validator: (value) {
                      if (value == null && controllerKotaLain.text.isEmpty) {
                        return 'Kota & kota lain harus diisi salah satu';
                      }
                    },
                    showSearchBox: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Layanan pengiriman barang hanya dapat dilakukan untuk kota-kota yang tercantum pada daftar di atas. Jika lokasi Anda tidak tercantum, tuliskan nama kota Anda pada kota di bawah ini:',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerKotaLain,
                    keyboardType: TextInputType.streetAddress,
                    validator: (value) {
                      if (value!.isEmpty &&
                          _kotaKey.currentState!.getSelectedItem == null) {
                        return 'Kota & kota lain harus diisi salah satu';
                      }
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.mapMarkerAlt),
                      hintText: 'Nama Kota',
                      labelText: 'Kota Lain',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerKodePos,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return 'Silahkan masukan kode pos min 5 digit';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.codepen),
                      hintText: '55288',
                      labelText: 'Kode Pos',
                    ),
                  ),
                  // const SizedBox(height: 24),
                  // Row(
                  //   children: [
                  //     SizedBox(
                  //       width: 90,
                  //       child: TextFormField(
                  //         controller: controllerTelpNegara,
                  //         keyboardType: TextInputType.number,
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return '*';
                  //           }
                  //           return null;
                  //         },
                  //         maxLength: 2,
                  //         decoration: getInputDecoration().copyWith(
                  //           contentPadding:
                  //               const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  //           prefixIcon: const Icon(FontAwesomeIcons.phoneAlt),
                  //           hintText: '62',
                  //           labelText: 'Telp',
                  //           counterText: "",
                  //         ),
                  //       ),
                  //     ),
                  //     const Padding(
                  //       padding: EdgeInsets.all(4.0),
                  //       child: Icon(
                  //         FontAwesomeIcons.minus,
                  //         size: 12,
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 60,
                  //       child: TextFormField(
                  //         controller: controllerTelpDaerah,
                  //         keyboardType: TextInputType.number,
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return '*';
                  //           }
                  //           return null;
                  //         },
                  //         maxLength: 3,
                  //         decoration: getInputDecoration().copyWith(
                  //           contentPadding: const EdgeInsets.all(14),
                  //           hintText: '274',
                  //           labelText: '',
                  //           counterText: "",
                  //         ),
                  //       ),
                  //     ),
                  //     const Padding(
                  //       padding: EdgeInsets.all(4.0),
                  //       child: Icon(
                  //         FontAwesomeIcons.minus,
                  //         size: 12,
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: TextFormField(
                  //         controller: controllerTelp,
                  //         keyboardType: TextInputType.number,
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return '* min 5 digit';
                  //           }
                  //           return null;
                  //         },
                  //         maxLength: 8,
                  //         decoration: getInputDecoration().copyWith(
                  //           contentPadding: const EdgeInsets.all(14),
                  //           hintText: '554444',
                  //           labelText: '',
                  //           counterText: "",
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 24),
                  // Row(
                  //   children: [
                  //     SizedBox(
                  //       width: 90,
                  //       child: TextFormField(
                  //         controller: controllerFaxNegara,
                  //         keyboardType: TextInputType.number,
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return '*';
                  //           }
                  //           return null;
                  //         },
                  //         maxLength: 2,
                  //         decoration: getInputDecoration().copyWith(
                  //           contentPadding:
                  //               const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  //           prefixIcon: const Icon(FontAwesomeIcons.fax),
                  //           hintText: '62',
                  //           labelText: 'Fax',
                  //           counterText: "",
                  //         ),
                  //       ),
                  //     ),
                  //     const Padding(
                  //       padding: EdgeInsets.all(4.0),
                  //       child: Icon(
                  //         FontAwesomeIcons.minus,
                  //         size: 12,
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 60,
                  //       child: TextFormField(
                  //         controller: controllerFaxDaerah,
                  //         keyboardType: TextInputType.number,
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return '*';
                  //           }
                  //           return null;
                  //         },
                  //         maxLength: 3,
                  //         decoration: getInputDecoration().copyWith(
                  //           contentPadding: const EdgeInsets.all(14),
                  //           hintText: '274',
                  //           labelText: '',
                  //           counterText: "",
                  //         ),
                  //       ),
                  //     ),
                  //     const Padding(
                  //       padding: EdgeInsets.all(4.0),
                  //       child: Icon(
                  //         FontAwesomeIcons.minus,
                  //         size: 12,
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: TextFormField(
                  //         controller: controllerFax,
                  //         keyboardType: TextInputType.number,
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return '*';
                  //           }
                  //           return null;
                  //         },
                  //         maxLength: 8,
                  //         decoration: getInputDecoration().copyWith(
                  //           contentPadding: const EdgeInsets.all(14),
                  //           hintText: '554444',
                  //           labelText: '',
                  //           counterText: "",
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 24),
                  // TextFormField(
                  //   controller: controllerUrl,
                  //   keyboardType: TextInputType.url,
                  //   validator: (value) {
                  //     if (value!.isEmpty) {
                  //       return 'Silahkan masukan alamat website';
                  //     }
                  //     return null;
                  //   },
                  //   decoration: getInputDecoration().copyWith(
                  //     prefixIcon: const Icon(FontAwesomeIcons.link),
                  //     hintText: 'www.example.com',
                  //     labelText: 'Situs Web',
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                      onPressed: () {
                        print("aaaa");
                        FocusScope.of(context).unfocus();

                        if (_keyDaftar.currentState!.validate()) {
                          daftar().then((value) {
                            if (value['daftar']) {
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
                                          controllerUsername.clear();
                                          controllerPassword.clear();
                                          controllerUlangiPassword.clear();
                                          controllerNama.clear();
                                          controllerEmail.clear();
                                          controllerSelular.clear();

                                          controllerAlamatLengkap.clear();
                                          controllerKotaLain.clear();
                                          controllerKodePos.clear();

                                          _kotaKey.currentState!.clear();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              showDialog<void>(
                                context: context,
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
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              // Fluttertoast.showToast(
                              //     msg: value['msg'],
                              //     toastLength: Toast.LENGTH_LONG,
                              //     gravity: ToastGravity.CENTER,
                              //     backgroundColor:
                              //         Colors.black.withOpacity(0.7));
                            }
                          });
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Silahkan Lengkapi data diri Anda',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.black.withOpacity(0.7));
                        }
                      },
                      child: const Text('Daftar')),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
