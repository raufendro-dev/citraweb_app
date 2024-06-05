// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom; // that is

import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PilihAlamatScreen extends StatelessWidget {
  const PilihAlamatScreen({Key? key, this.isDiambil = 0, this.mkIdTujuan = 0})
      : super(key: key);
  final int isDiambil;
  final int mkIdTujuan;

  Future<List<Map<String, dynamic>>> fetchAlamat() async {
    String id = await AuthService().idUser;
    String sessionI = await AuthService().sessId;

    final List<Map<String, dynamic>> listAlamat = [];
    final responseAlamat = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/keranjang/ganti-tujuan/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionI&isDiambil=$sessionI&MKid_tujuan=$mkIdTujuan'));
    if (responseAlamat.statusCode == 200) {
      final Map alamat = jsonDecode(responseAlamat.body);
      if (alamat['data'].isNotEmpty) {
        for (var detailAlamat in alamat['data']) {
          listAlamat.add(detailAlamat);
        }
      }
    } else {
      print('Failed to load list alamat');
    }
    // print(listAlamat);
    return listAlamat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Alamat'),
        actions: [
          IconButton(
              onPressed: () {
                launch(Config.baseUrlApi + 'toko_tujuan_baru/');
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchAlamat(),
          builder: (context, snapsot) {
            if (snapsot.hasData) {
              final objAlamat = snapsot.data!.first;
              return Column(
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
                        //open URL in webview, or launch URL in browser, or any other logic here
                        if (await canLaunch(url!)) {
                          await launch(
                            url,
                          );
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ),
                  if (objAlamat['ada_data_pengiriman_berdasarkan_profil'])
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(
                            context,
                            jsonEncode({"isDiambil": 0, "MKid_tujuan": 0}),
                          );
                        },
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        tileColor: Theme.of(context).colorScheme.background,
                        title:
                            objAlamat['ada_data_pengiriman_berdasarkan_profil']
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
                            if (objAlamat['data_pengiriman_berdasarkan_profil']
                                .first['telp']
                                .isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: Text(objAlamat[
                                        'data_pengiriman_berdasarkan_profil']
                                    .first['telp']),
                              ),
                            if (objAlamat['data_pengiriman_berdasarkan_profil']
                                .first['perusahaan']
                                .isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: Text(objAlamat[
                                        'data_pengiriman_berdasarkan_profil']
                                    .first['perusahaan']),
                              ),
                            if (objAlamat['data_pengiriman_berdasarkan_profil']
                                .first['alamat']
                                .isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: Text(objAlamat[
                                        'data_pengiriman_berdasarkan_profil']
                                    .first['alamat']),
                              ),
                            if (objAlamat['data_pengiriman_berdasarkan_profil']
                                .first['nama_kota']
                                .isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: Text(objAlamat[
                                        'data_pengiriman_berdasarkan_profil']
                                    .first['nama_kota']),
                              ),
                            if (objAlamat['data_pengiriman_berdasarkan_profil']
                                .first['kodepos']
                                .isNotEmpty)
                              Text(objAlamat[
                                      'data_pengiriman_berdasarkan_profil']
                                  .first['kodepos']),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (mkIdTujuan == 0 && isDiambil == 0)
                              Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            const Icon(Icons.location_on),
                          ],
                        ),
                      ),
                    ),
                  if (objAlamat['ada_data_pilihan_pengiriman'])
                    ...objAlamat['data_pilihan_pengiriman'].map(
                      (elem) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () {
                              Navigator.pop(
                                context,
                                jsonEncode({
                                  "isDiambil": 0,
                                  "MKid_tujuan": int.parse(elem['MKid_tujuan'])
                                }),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            tileColor: Theme.of(context).colorScheme.background,
                            title: elem['nama'].isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      elem['nama'],
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
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
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (mkIdTujuan ==
                                        int.parse(elem['MKid_tujuan']) &&
                                    isDiambil == 0)
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
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
