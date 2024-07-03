// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/screens/log_status_rma.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mikrotik/main.dart' show slideDirection;

class DetailRmaScreen extends StatelessWidget {
  const DetailRmaScreen({Key? key, required this.noRMA}) : super(key: key);

  final String noRMA;

  Future<Map<String, dynamic>> fetchDetailRMA() async {
    Map<String, dynamic> detailRMA = {};
    final auth = AuthService();

    final responseDetailRMA = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/rma/detail/?key=0cc7da679bea04fea453c8062e06514d&iduser=${await auth.idUser}&sess_id=${await auth.sessId}&no_RMA=$noRMA'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/rma/detail/?key=0cc7da679bea04fea453c8062e06514d&iduser=${await auth.idUser}&sess_id=${await auth.sessId}&no_RMA=$noRMA'));
    if (responseDetailRMA.statusCode == 200) {
      print('fetchDetailRMA');
      final Map rma = jsonDecode(responseDetailRMA.body);
      if (rma['data'].isNotEmpty) {
        detailRMA = rma['data'].first;
      }
    } else {
      print('Failed to load rma');
    }
    return detailRMA;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian RMA'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetailRMA(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final rma = snapshot.data!;
            print(rma);
            return Container(
              height: double.infinity,
              color: Theme.of(context).colorScheme.background,
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, top: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nama',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            rma['user_nama'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No RMA',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            rma['no_RMA'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    if (rma['tgl_return'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Return',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              rma['tgl_return'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status RMA',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            rma['status_txt_RMA'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    if (rma['estimasi_waktu'].toString() != null &&
                        rma['estimasi_waktu'] != "")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimasi Waktu',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              rma['estimasi_waktu'] + ' Hari',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail RMA',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ...rma['data_rma'].map((barang) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    barang['nama_barang'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (barang['no_invoice'] != null &&
                                      barang['no_invoice'] != "")
                                    Text(
                                        'No Invoice : ' + barang['no_invoice']),
                                  if (barang['type'] != null &&
                                      barang['detail'] != null)
                                    Text(barang['type'] +
                                        ' : ' +
                                        barang['detail']),
                                  Text('Keluhan : ' + barang['keluhan']),
                                  Text(
                                      'Kelengkapan : ' + barang['kelengkapan']),
                                  Text('Perbaikan : ' + barang['perbaikan']),
                                  const Text('Penggantian :'),
                                  if (barang['ada_data_pergantian'])
                                    ...barang['data_pergantian'].map((ganti) =>
                                        Text(ganti['type'] +
                                            ' ' +
                                            ganti['keterangan'])),
                                  if (barang['gambar_segel'] != null &&
                                      barang['gambar_segel'] != "")
                                    const Text('Gambar Segel :'),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (barang['gambar_segel'] != null &&
                                      barang['gambar_segel'] != "")
                                    Image.network(barang['gambar_segel']),
                                  const Divider(height: 12),
                                ],
                              ))
                        ],
                      ),
                    ),
                    if (rma['info_rma'].toString() != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Info RMA',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Html(
                              data: rma['info_rma'],
                              style: {
                                "*": Style(
                                  padding: const EdgeInsets.only(top: 1),
                                  margin: EdgeInsets.zero,
                                )
                              },
                            ),
                          ],
                        ),
                      ),
                    if (rma['download_rma_form_url'] != '#' ||
                        rma['download_rma_alamat_url'] != '#' ||
                        rma['download_uiDlText_url'] != '#')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Download',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            if (rma['download_rma_form_url'] != '#')
                              ElevatedButton(
                                onPressed: () async {
                                  final url = rma['download_rma_form_url'];
                                  print(url);
                                  await launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                  // if (await canLaunch(url)) {
                                  //   await launch(
                                  //     url,
                                  //   );
                                  // } else {
                                  //   throw 'Could not launch $url';
                                  // }
                                },
                                child: Text(rma['download_rma_form']),
                              ),
                            if (rma['download_rma_alamat_url'] != '#')
                              ElevatedButton(
                                onPressed: () async {
                                  final url = rma['download_rma_alamat_url'];
                                  print(url);
                                  await launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                  // if (await canLaunch(url)) {
                                  //   await launch(
                                  //     url,
                                  //   );
                                  // } else {
                                  //   throw 'Could not launch $url';
                                  // }
                                },
                                child: Text(rma['download_rma_alamat']),
                              ),
                            if (rma['download_uiDlText_url'] != '#')
                              ElevatedButton(
                                onPressed: () async {
                                  final url = rma['download_uiDlText_url'];
                                  print(url);
                                  await launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                  // if (await canLaunch(url)) {
                                  //   await launch(
                                  //     url,
                                  //   );
                                  // } else {
                                  //   throw 'Could not launch $url';
                                  // }
                                },
                                child: Text(rma['download_uiDlText']),
                              ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Log Status',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                splashRadius: 18,
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.keyboard_arrow_right),
                                onPressed: () {
                                  // print(widget.noNota);
                                  Navigator.of(context).push(_createRoute(
                                      LogStatusRma(
                                        noRma: noRMA,
                                      ),
                                      slideDirection.toLeft));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
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
}
