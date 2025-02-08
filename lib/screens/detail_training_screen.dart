// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom; // that is

import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/screens/daftar_training_sukses.dart';
import 'package:mikrotik/screens/home_page_screen.dart';
import 'package:mikrotik/screens/login_screen.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTrainingScreen extends StatefulWidget {
  DetailTrainingScreen(
      {Key? key, required this.id, this.initialData = const {}})
      : super(key: key);
  final int id;
  final Map<String, dynamic> initialData;
  static const routeName = 'DetailTrainingScreen';

  @override
  State<DetailTrainingScreen> createState() => _DetailTrainingScreenState();
}

class _DetailTrainingScreenState extends State<DetailTrainingScreen> {
  late final futureProfile = fetchProfile();

  var iduser;

  var sessid;

  Future<Map<String, dynamic>> fetchTraining() async {
    Map<String, dynamic> listTraining = {};

    print(Uri.parse(Config.baseUrlApi +
        'app-api/training/detail/?id=${widget.id}&key=0cc7da679bea04fea453c8062e06514d&iduser=$iduser&sess_id=$sessid'));
    // print(await auth.strDataLogin);

    print('jancukkk');
    print(iduser);

    //! tambah session id

    final responseTraining = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/training/detail/?id=${widget.id}&key=0cc7da679bea04fea453c8062e06514d&iduser=$iduser&sess_id=$sessid'));

    if (responseTraining.statusCode == 200) {
      print('fetchTraining');
      final Map training = jsonDecode(responseTraining.body);
      if (training['data'].isNotEmpty) {
        listTraining = training['data'].first;
      }
    } else {
      print('Failed to load Detail Training');
    }
    print(listTraining);
    return listTraining;
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    Map<String, dynamic> profileObj = {};

    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());

    final responseProfile = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/profil/?key=0cc7da679bea04fea453c8062e06514d&iduser=${dataLogin['MKid']}&sess_id=${dataLogin['sess_id']}'));
    if (responseProfile.statusCode == 200) {
      print('fetchProfile');
      final Map profil = jsonDecode(responseProfile.body);
      if (profil['data'].isNotEmpty) {
        profileObj = profil['data'].first;
      }
    } else {
      print('Failed to load Profile');
    }
    return profileObj;
  }

  cek() async {
    var auth = await AuthService();
    var dataLogin = jsonDecode((await AuthService().strDataLogin).toString());
    var _iduser = await auth.idUser;
    var _sessid = await auth.sessId;

    if (dataLogin != null) {
      setState(() {
        iduser = _iduser;
        sessid = _sessid;
      });
    } else {
      setState(() {
        iduser = '0';
        sessid = '0';
      });
      print('blokk');
    }
  }

  @override
  void initState() {
    super.initState();
    cek();
    fetchTraining();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Theme.of(context).colorScheme.background,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Detail Training'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: Future.delayed(
            const Duration(milliseconds: 250),
            () => fetchTraining(),
          ),
          initialData:
              widget.initialData.isNotEmpty ? widget.initialData : null,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var training = snapshot.data!;
              return Container(
                color: Theme.of(context).colorScheme.background,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              training['nama'],
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              training['kota'],
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            ...training['tanggal'].split(',').map(
                                  (value) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      value[0] == ' '
                                          ? value.substring(1)
                                          : value,
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                    ),
                                  ),
                                ),
                            Text(
                              training['jam'],
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                      Html(
                          data: '<b>Kapasitas:</b> ' +
                              training['kapasitas'] +
                              ' orang'),
                      Html(
                        data: '<b>Lokasi:</b><br>' + training['lokasi'],
                        onLinkTap: (url, _, __, ___) {
                          launchUrl(Uri.parse(url.toString()));
                        },
                      ),
                      Html(
                        data: training['keterangan']
                            .toString()
                            .replaceAll("Â", ""),
                        customRender: {
                          "table": (context, child) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: (context.tree as TableLayoutElement)
                                  .toWidget(context),
                            );
                          },
                        },
                        onLinkTap: (String? url,
                            RenderContext context,
                            Map<String, String> attributes,
                            dom.Element? element) async {
                          print(url);
                          await launchUrl(Uri.parse(url!),
                              mode: LaunchMode.externalApplication);
                          // if (await canLaunch(url!)) {
                          //   await launch(
                          //     url,
                          //   );
                          // } else {
                          //   throw 'Could not launch $url';
                          // }
                        },
                      ),
                      Html(data: '<b>Materi:</b><br>' + training['materi']),
                      Html(
                        data: training['akomodasi'],
                        customRender: {
                          "iframe": (context, child) {
                            var url = context.tree.attributes['src']!;
                            print(url);
                            if (url.contains('maps')) {
                              return child;
                            }
                            return null;
                          },
                        },
                      ),
                      Html(data: training['syarat']),
                      Html(data: training['fasilitas']),
                      ElevatedButton(
                        onPressed: () async {
                          if (await AuthService().cekLogin(context)) {
                            final profileObj = await futureProfile;
                            print(profileObj);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DaftarTrainingScreen(
                                  id: widget.id,
                                  training: training,
                                  profileObj: profileObj,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      LoginScreen(),
                                )).then((value) async {
                              if ((await AuthService().strDataLogin)
                                  .toString()
                                  .isNotEmpty) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    HomePageScreen.routeName,
                                    (Route<dynamic> route) => false,
                                    arguments: 1);

                                Navigator.of(context).pushNamed(
                                    DetailTrainingScreen.routeName,
                                    arguments: widget.id);
                              }
                            });
                          }
                        },
                        child: const Text('Pendaftaran'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Download dan lihat versi cetak:'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              if (await AuthService().cekLogin(context)) {
                                var url = training['training_undangan'];
                                await launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          LoginScreen(),
                                    )).then((value) async {
                                  if ((await AuthService().strDataLogin)
                                      .toString()
                                      .isNotEmpty) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            HomePageScreen.routeName,
                                            (Route<dynamic> route) => false,
                                            arguments: 1);

                                    Navigator.of(context).pushNamed(
                                        DetailTrainingScreen.routeName,
                                        arguments: widget.id);
                                  }
                                });
                              }
                              // if (await canLaunch(url)) {
                              //   await launch(
                              //     url,
                              //   );
                              // } else {
                              //   throw 'Could not launch $url';
                              // }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: const Text('Surat Undangan'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () async {
                              if (await AuthService().cekLogin(context)) {
                                var url = training['training_brosur'];
                                await launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          LoginScreen(),
                                    )).then((value) async {
                                  if ((await AuthService().strDataLogin)
                                      .toString()
                                      .isNotEmpty) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            HomePageScreen.routeName,
                                            (Route<dynamic> route) => false,
                                            arguments: 1);

                                    Navigator.of(context).pushNamed(
                                        DetailTrainingScreen.routeName,
                                        arguments: widget.id);
                                  }
                                });
                              }
                              // if (await canLaunch(url)) {
                              //   await launch(
                              //     url,
                              //   );
                              // } else {
                              //   throw 'Could not launch $url';
                              // }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: const Text('Brosur Training'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class DaftarTrainingScreen extends StatelessWidget {
  DaftarTrainingScreen({
    Key? key,
    required this.training,
    required this.profileObj,
    required this.id,
  }) : super(key: key);

  final int id;
  final Map<String, dynamic>? training;
  final Map<String, dynamic> profileObj;
  final noSertifikat = TextEditingController();
  final keyForm = GlobalKey<FormState>();
  final authService = AuthService();

  Future<Map<String, dynamic>> daftarTraining() async {
    var dataLogin = jsonDecode((await authService.strDataLogin).toString());
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/training/daftar/'),
      body: jsonEncode({
        "key": "0cc7da679bea04fea453c8062e06514d",
        "iduser": dataLogin['MKid'],
        "sess_id": dataLogin['sess_id'],
        "ip": (await AuthService.getIPAddress()),
        "id": id,
        "mtcom_cert": noSertifikat.text,
      }),
    );
    print(res.body);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'].first;
    }
    return {
      "diganti": false,
      "msg": "Terjadi kesalahan saat penggantian password"
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: const CloseButton(), title: const Text('Daftar Training')),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: Theme.of(context).colorScheme.background,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 24,
                ),
                child: Form(
                  key: keyForm,
                  child: Column(
                    children: [
                      Text(
                        'Kelas Training',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kelas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              training!['nama'],
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kota',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(training!['kota']),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tanggal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ...training!['tanggal'].split(',').map((value) =>
                                  Text(value[0] == ' '
                                      ? value.substring(1)
                                      : value)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jam',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(training!['jam']),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 24),
                      Text(
                        'Peserta',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nama',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(profileObj['nama']),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Perusahaan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(profileObj['perusahaan']),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(profileObj['email']),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Telp',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(profileObj['telp']),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Selular',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(profileObj['selular']),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      if (training!['isadvanced'] == '1')
                        Column(
                          children: [
                            Text(
                              'Sertifikat Basic Training',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: noSertifikat,
                              validator: (value) {
                                if (value == '') {
                                  return 'Harap cantumkan nomor sertifikat';
                                }
                              },
                              decoration: const InputDecoration(
                                  hintText: 'No Sertifikat'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ElevatedButton(
                        onPressed: () async {
                          if (keyForm.currentState!.validate()) {
                            daftarTraining().then((value) {
                              print(value);
                              if (value['isdaftar']) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  HomePageScreen.routeName,
                                  (Route<dynamic> route) => false,
                                  arguments: 4,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DaftarTrainingSukses(
                                      msg: value['msg'],
                                    ),
                                  ),
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: value['msg'],
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.7),
                                  textColor: Colors.white,
                                );
                              }
                            });
                          }
                        },
                        child: const Text('Daftar'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
