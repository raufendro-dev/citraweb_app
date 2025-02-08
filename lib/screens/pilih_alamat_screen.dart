// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom; // that is
import 'package:mikrotik/main.dart';
import 'package:mikrotik/screens/editalamat_screen.dart';
import 'package:mikrotik/screens/tambahalamat_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/providers/alamat_provider.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PilihAlamatScreen extends StatefulWidget {
  const PilihAlamatScreen({Key? key, this.isDiambil = 0, this.mkIdTujuan = 0})
      : super(key: key);
  final int isDiambil;
  final int mkIdTujuan;

  @override
  State<PilihAlamatScreen> createState() => _PilihAlamatScreenState();
}

class _PilihAlamatScreenState extends State<PilihAlamatScreen> {
  final List<Map<String, dynamic>> listAlamat = [];
  Future<void> deleteAlamatTujuan(int idal) async {
    String id = await AuthService().idUser;
    String sessionI = await AuthService().sessId;
    final String url =
        "https://mkt.citraweb.co.id/app-api/keranjang/alamat-tujuan-hapus/"
        "?key=0cc7da679bea04fea453c8062e06514d"
        "&iduser=$id"
        "&sess_id=$sessionI"
        "&id=$idal";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print("Alamat berhasil dihapus.");
        fetchAlamat();
      } else {
        print("Gagal menghapus alamat. Kode: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchAlamat() async {
    String id = await AuthService().idUser;
    String sessionI = await AuthService().sessId;
    List<Map<String, dynamic>> _listAlamat = [];

    final responseAlamat = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/keranjang/ganti-tujuan/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionI&isDiambil=$sessionI&MKid_tujuan=${widget.mkIdTujuan}'));

    print(Config.baseUrlApi +
        'app-api/keranjang/ganti-tujuan/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionI&isDiambil=$sessionI&MKid_tujuan=${widget.mkIdTujuan}');
    if (responseAlamat.statusCode == 200) {
      listAlamat.clear();
      final Map alamat = jsonDecode(responseAlamat.body);
      if (alamat['data'].isNotEmpty) {
        for (var detailAlamat in alamat['data']) {
          _listAlamat.add(detailAlamat);
        }
      }
    } else {
      print('Failed to load list alamat');
    }
    setState(() {
      listAlamat.clear();
      listAlamat.addAll(_listAlamat);
    });
    // print(listAlamat);
    return listAlamat;
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
  void initState() {
    super.initState();
    fetchAlamat();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> jsonData =
        Provider.of<alamatProvider>(context, listen: false).toJson();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Alamat'),
        actions: [
          IconButton(
              onPressed: () {
                // launch(Config.baseUrlApi + 'toko_tujuan_baru/');
                Navigator.of(context)
                    .push(
                  _createRoute(AddressFormScreen(), slideDirection.toLeft),
                )
                    .then(
                  (value) async {
                    print("Jancukkkkkk");
                    print(value);
                    if (value == true) {
                      await fetchAlamat();
                    }
                  },
                );
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchAlamat(),
          builder: (context, snapsot) {
            if (snapsot.hasData) {
              final objAlamat = snapsot.data!.first;
              print(objAlamat);
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(
                        top: 8,
                        bottom: 12,
                      ),
                      color: Theme.of(context).colorScheme.background,
                      child: Html(
                        data:
                            'Perubahan atau penambahan alamat baru dapat dilakukan di <a href="' +
                                Config.baseUrlApi +
                                'toko_tujuan_baru/">sini</a>',
                        style: {
                          "a": Style(
                            textDecoration: TextDecoration.none,
                          ),
                        },
                        onLinkTap: (String? url,
                            RenderContext context,
                            Map<String, String> attributes,
                            dom.Element? element) async {
                          print(url);

                          await launchUrl(
                            Uri.parse(url.toString()),
                          );
                        },
                      ),
                    ),
                    if (objAlamat['ada_data_pengiriman_berdasarkan_profil'])
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () {
                            print('tess2');

                            Navigator.pop(
                              context,
                              jsonEncode({"isDiambil": 0, "MKid_tujuan": 0}),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          tileColor: Theme.of(context).colorScheme.background,
                          title: objAlamat[
                                  'ada_data_pengiriman_berdasarkan_profil']
                              ? Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        objAlamat[
                                                'data_pengiriman_berdasarkan_profil']
                                            .first['nama'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                      Text(
                                        ' [Utama]',
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                      )
                                    ],
                                  ),
                                )
                              : const Text(''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (objAlamat[
                                      'data_pengiriman_berdasarkan_profil']
                                  .first['telp']
                                  .isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: Text(objAlamat[
                                          'data_pengiriman_berdasarkan_profil']
                                      .first['telp']),
                                ),
                              if (objAlamat[
                                      'data_pengiriman_berdasarkan_profil']
                                  .first['perusahaan']
                                  .isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: Text(objAlamat[
                                          'data_pengiriman_berdasarkan_profil']
                                      .first['perusahaan']),
                                ),
                              if (objAlamat[
                                      'data_pengiriman_berdasarkan_profil']
                                  .first['alamat']
                                  .isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: Text(objAlamat[
                                          'data_pengiriman_berdasarkan_profil']
                                      .first['alamat']),
                                ),
                              if (objAlamat[
                                      'data_pengiriman_berdasarkan_profil']
                                  .first['nama_kota']
                                  .isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: Text(objAlamat[
                                          'data_pengiriman_berdasarkan_profil']
                                      .first['nama_kota']),
                                ),
                              if (objAlamat[
                                      'data_pengiriman_berdasarkan_profil']
                                  .first['kodepos']
                                  .isNotEmpty)
                                Text(objAlamat[
                                        'data_pengiriman_berdasarkan_profil']
                                    .first['kodepos']),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  TextButton(
                                      onPressed: null,
                                      child: Text("Edit Alamat")),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  TextButton(
                                      onPressed: null,
                                      child: Text("Hapus Alamat")),
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (widget.mkIdTujuan == 0 &&
                                  widget.isDiambil == 0)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              const Icon(Icons.location_on),
                            ],
                          ),
                        ),
                      ),
                    if (objAlamat['ada_data_pilihan_pengiriman'] == true &&
                        objAlamat['ada_data_pilihan_pengiriman'] != null)
                      ...objAlamat['data_pilihan_pengiriman'].map(
                        (elem) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () {
                                print('tesss');
                                Navigator.pop(
                                  context,
                                  jsonEncode({
                                    "isDiambil": 0,
                                    "MKid_tujuan":
                                        int.parse(elem['MKid_tujuan'])
                                  }),
                                );
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              tileColor:
                                  Theme.of(context).colorScheme.background,
                              title: elem['nama'].isNotEmpty
                                  ? Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        elem['nama'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                    )
                                  : const Text(''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (elem['telp'].isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Text(elem['telp']),
                                    ),
                                  if (elem['perusahaan'].isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Text(elem['perusahaan']),
                                    ),
                                  if (elem['alamat'].isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Text(elem['alamat']),
                                    ),
                                  if (elem['nama_kota'].isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: Text(elem['nama_kota']),
                                    ),
                                  if (elem['kodepos'].isNotEmpty)
                                    Text(elem['kodepos']),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(
                                              _createRoute(
                                                  EditAddressFormScreen(
                                                      idal: int.parse(
                                                          elem['MKid_tujuan'])),
                                                  slideDirection.toLeft),
                                            )
                                                .then(
                                              (value) async {
                                                print("Jancukkkkkk");
                                                print(value);
                                                if (value == true) {
                                                  await fetchAlamat();
                                                }
                                              },
                                            );
                                          },
                                          child: Text("Edit Alamat")),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      TextButton(
                                          onPressed: () async {
                                            await deleteAlamatTujuan(
                                                int.parse(elem['MKid_tujuan']));
                                          },
                                          child: Text("Hapus Alamat")),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (widget.mkIdTujuan ==
                                          int.parse(elem['MKid_tujuan']) &&
                                      widget.isDiambil == 0)
                                    Icon(
                                      Icons.check,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  const Icon(Icons.location_on),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
          }),
    );
  }
}
