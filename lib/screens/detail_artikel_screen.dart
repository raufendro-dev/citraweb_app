// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom; // that is

import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailArtikelScreen extends StatelessWidget {
  const DetailArtikelScreen(
      {Key? key, required this.id, this.initialData = const {}})
      : super(key: key);
  final int id;
  final Map<String, dynamic> initialData;
  static const routeName = 'DetailArtikelScreen';

  Future<Map<String, dynamic>> fetchArtikel() async {
    Map<String, dynamic> listArtikel = {};

    final responseArtikel = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/artikel/detail/?id=$id&key=0cc7da679bea04fea453c8062e06514d'));
    if (responseArtikel.statusCode == 200) {
      print('fetchArtikel');
      final Map artikel = jsonDecode(responseArtikel.body);
      if (artikel['data'].isNotEmpty) {
        listArtikel = artikel['data'].first;
      }
    } else {
      print('Failed to load Detail Artikel');
    }
    return listArtikel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Theme.of(context).colorScheme.background,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Detail Berita'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: Future.delayed(
            const Duration(milliseconds: 250),
            () => fetchArtikel(),
          ),
          initialData: initialData.isNotEmpty ? initialData : null,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var artikel = snapshot.data!;
              return Container(
                color: Theme.of(context).colorScheme.background,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        artikel['judul'],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        artikel['nama_kategori'],
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(artikel['tanggal']),
                      Html(
                        data: artikel['isi'].toString().replaceAll("Â", ""),
                        customRender: {
                          "table": (context, child) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: (context.tree as TableLayoutElement)
                                  .toWidget(context),
                            );
                          }
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
