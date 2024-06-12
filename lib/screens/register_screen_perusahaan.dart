// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:mikrotik/services/auth_service.dart';
import '../models/dropdown_model.dart';
import 'dart:convert';
import 'package:image/image.dart' as Img;
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';

class RegisterPerusahaanScreen extends StatefulWidget {
  const RegisterPerusahaanScreen({Key? key}) : super(key: key);

  @override
  State<RegisterPerusahaanScreen> createState() => _RegisterPerusahaanScreen();
}

class _RegisterPerusahaanScreen extends State<RegisterPerusahaanScreen> {
  final _keyDaftar = GlobalKey<FormState>();

  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerUlangiPassword = TextEditingController();
  final controllerNama = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerSelular = TextEditingController();
  final controllerPerusahaan = TextEditingController();
  final controllerNoNPWP = TextEditingController();
  final controllerNoNPWP2 = TextEditingController();
  final controllerPerusahaanNPWP = TextEditingController();
  final controllerAlamatNPWP = TextEditingController();
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

  final _jenisPerusahaanKey = GlobalKey<DropdownSearchState<DropdownModel>>();
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
    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "ip": await AuthService.getIPAddress(),
      "tipe_akun": "2",
      "userid": controllerUsername.text,
      "password": controllerPassword.text,
      "password2": controllerUlangiPassword.text,
      "nama": controllerNama.text,
      "email": controllerEmail.text,
      "selular": controllerSelular.text,
      "perusahaan": controllerPerusahaan.text,
      "jenis": _jenisPerusahaanKey.currentState!.getSelectedItem!.id,
      "jabatan": controllerJabatan.text,
      "alamat": controllerAlamatLengkap.text,
      "kode_kota": _kotaKey.currentState!.getSelectedItem!.id,
      "kota_lain": controllerKotaLain.text,
      "kodepos": controllerKodePos.text,
      "telpnegara": controllerTelpNegara.text,
      "telpdaerah": controllerTelpDaerah.text,
      "telp": controllerTelp.text,
      "faxnegara": controllerFaxNegara.text,
      "faxdaerah": controllerFaxDaerah.text,
      "fax": controllerFax.text,
      "url": controllerUrl.text,
      "perusahaan_npwp": controllerPerusahaanNPWP.text,
      "alamat_npwp": controllerAlamatNPWP.text,
      "no_npwp": controllerNoNPWP.text,
      "foto_npwp": fileBase64,
      "tipefile": fileType.replaceAll(".", ""),
    });
    print(bodyPost);
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/daftar/'),
      body: bodyPost,
    );
    print(res.body);
    if (res.statusCode == 200) {
      print(jsonDecode(res.body)['data'].first);
      return jsonDecode(res.body)['data'].first;
    }
    return {"daftar": false, "msg": "Terjadi kesalahan saat pendaftaran"};
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

  File? _image;

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Set the image quality here (0 to 100)
    );
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
        try {
          // Get file format
          final Img.Image? image = Img.decodeImage(_image!.readAsBytesSync());
          if (image != null) {
            String imageType = _getImageType(_image!.path);
            print('Image type: $imageType');

            // Compress image while maintaining aspect ratio
            Img.Image compressedImage =
                Img.copyResize(image, width: 800); // Adjust the width as needed

            // Convert image to base64
            List<int> imageBytes = Img.encodeJpg(
                compressedImage); // Convert to JPG format to reduce size
            String base64Image = 'data:image/jpeg;base64,' +
                base64Encode(imageBytes); // Prepend the data URI format
            print('Base64 image: $base64Image');

            // Proceed with the compressed and encoded image...
          }
        } catch (e) {
          print('Error: $e');
        }
      } else {
        print('No image selected.');
      }
    });
  }

  String _getImageType(String imagePath) {
    String type = imagePath.split('.').last.toLowerCase();
    return type;
  }

  @override
  void initState() {
    super.initState();
    fetchJenisPerusahaan().then((value) {
      setState(() {
        listJenisPerusahaan = value;
      });
    });
    fetchKota().then((value) {
      setState(() {
        listKota = value;
      });
    });
  }

  String fileName = '';
  String fileBase64 = '';
  String fileType = '';
  String alertFile = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran Member'),
      ),
      body: SingleChildScrollView(
        child: Form(
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerPerusahaan,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan masukan nama perusahaan';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.building),
                      hintText: 'Citraweb',
                      labelText: 'Perusahaan',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownSearch<DropdownModel>(
                    key: _jenisPerusahaanKey,
                    items: listJenisPerusahaan,
                    dropdownSearchDecoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.building),
                      labelText: "Jenis Perusahaan",
                      contentPadding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                    ),
                    validator: (value) => value == null
                        ? "Selahkan pilih jenis perusahaan"
                        : null,
                    showSearchBox: true,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerJabatan,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan masukan jabatan';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.building),
                      hintText: 'Karyawan',
                      labelText: 'Jabatan',
                    ),
                  ),
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
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: controllerTelpNegara,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '*';
                            }
                            return null;
                          },
                          maxLength: 2,
                          decoration: getInputDecoration().copyWith(
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            prefixIcon: const Icon(FontAwesomeIcons.phoneAlt),
                            hintText: '62',
                            labelText: 'Telp',
                            counterText: "",
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          FontAwesomeIcons.minus,
                          size: 12,
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          controller: controllerTelpDaerah,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '*';
                            }
                            return null;
                          },
                          maxLength: 3,
                          decoration: getInputDecoration().copyWith(
                            contentPadding: const EdgeInsets.all(14),
                            hintText: '274',
                            labelText: '',
                            counterText: "",
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          FontAwesomeIcons.minus,
                          size: 12,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controllerTelp,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '* min 5 digit';
                            }
                            return null;
                          },
                          maxLength: 8,
                          decoration: getInputDecoration().copyWith(
                            contentPadding: const EdgeInsets.all(14),
                            hintText: '554444',
                            labelText: '',
                            counterText: "",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: controllerFaxNegara,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '*';
                            }
                            return null;
                          },
                          maxLength: 2,
                          decoration: getInputDecoration().copyWith(
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            prefixIcon: const Icon(FontAwesomeIcons.fax),
                            hintText: '62',
                            labelText: 'Fax',
                            counterText: "",
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          FontAwesomeIcons.minus,
                          size: 12,
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          controller: controllerFaxDaerah,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '*';
                            }
                            return null;
                          },
                          maxLength: 3,
                          decoration: getInputDecoration().copyWith(
                            contentPadding: const EdgeInsets.all(14),
                            hintText: '274',
                            labelText: '',
                            counterText: "",
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          FontAwesomeIcons.minus,
                          size: 12,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controllerFax,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '*';
                            }
                            return null;
                          },
                          maxLength: 8,
                          decoration: getInputDecoration().copyWith(
                            contentPadding: const EdgeInsets.all(14),
                            hintText: '554444',
                            labelText: '',
                            counterText: "",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: controllerUrl,
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan masukan alamat website';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.link),
                      hintText: 'www.example.com',
                      labelText: 'Situs Web',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerNoNPWP,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,4}(-\d{0,4})?(-\d{0,4})?$'),
                      ),
                      NumberInputFormatter(),
                    ],
                    decoration: getInputDecoration().copyWith(
                      hintText: '####-####-####',
                      labelText: 'No NPWP',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerPerusahaanNPWP,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan masukan nama pada NPWP perusahaan';
                      }
                      return null;
                    },
                    decoration: getInputDecoration().copyWith(
                      prefixIcon: const Icon(FontAwesomeIcons.building),
                      hintText: 'Citraweb',
                      labelText: 'Perusahaan NPWP',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllerAlamatNPWP,
                    keyboardType: TextInputType.streetAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Silahkan masukan alamat npwp';
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
                      labelText: 'Alamat Lengkap NPWP',
                    ),
                  ),
                  const SizedBox(height: 24),
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

                            print(fileType);
                          },
                          child: Text(
                            fileBase64 != ''
                                ? 'Ubah Foto NPWP'
                                : 'Pilih Foto NPWP',
                            textAlign: TextAlign.center,
                          )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                      onPressed: () {
                        if (fileBase64 != '') {
                          FocusScope.of(context).unfocus();
                          if (_keyDaftar.currentState!.validate()) {
                            showLoadingDialog();
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
                                            controllerPerusahaan.clear();
                                            controllerJabatan.clear();
                                            controllerAlamatLengkap.clear();
                                            controllerKotaLain.clear();
                                            controllerKodePos.clear();
                                            controllerTelpNegara.clear();
                                            controllerTelpDaerah.clear();
                                            controllerTelp.clear();
                                            controllerFaxNegara.clear();
                                            controllerFaxDaerah.clear();
                                            controllerFax.clear();
                                            controllerUrl.clear();
                                            controllerAlamatNPWP.clear();
                                            controllerNoNPWP.clear();
                                            controllerPerusahaanNPWP.clear();

                                            _jenisPerusahaanKey.currentState!
                                                .clear();
                                            _kotaKey.currentState!.clear();
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                Navigator.of(context).pop();
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

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > oldValue.text.length) {
      final StringBuffer newText = StringBuffer();
      for (int i = 0; i < newValue.text.length; i++) {
        if ((i == 4 || i == 9) && newValue.text[i] != '-') {
          newText.write('-');
        }
        newText.write(newValue.text[i]);
      }
      return TextEditingValue(
        text: newText.toString(),
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    return newValue;
  }
}
