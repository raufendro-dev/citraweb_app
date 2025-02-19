// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom; // that is

class PageScreen extends StatelessWidget {
  const PageScreen({Key? key, required this.title, required this.idPage})
      : super(key: key);
  final String title;
  final int idPage;

  Future<Map<String, dynamic>> fetchPage() async {
    Map<String, dynamic> pageObj = {};

    final responsePage = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/pages/detail/?id=$idPage&key=0cc7da679bea04fea453c8062e06514d'));
    if (responsePage.statusCode == 200) {
      print('fetchPage');
      final Map page = jsonDecode(responsePage.body);
      if (page['data'].isNotEmpty) {
        // for (var infoProfile in profil['data']) {
        //   // pageObj.add(infoProfile);

        // }
        pageObj = page['data'].first;
      }
    } else {
      print('Failed to load Page');
    }
    return pageObj;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: fetchPage(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(title: Text(title)),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(title: Text(snapshot.data!['judul'])),
            body: Container(
              color: Theme.of(context).colorScheme.background,
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                  child: Html(
                data: snapshot.data!['isi'],
                onLinkTap: (String? url,
                    RenderContext context,
                    Map<String, String> attributes,
                    dom.Element? element) async {
                  //open URL in webview, or launch URL in browser, or any other logic here
                  if (!url!.contains('http')) {
                    url = Config.baseUrlApi + url;
                    url = url.replaceAll('//', '/');
                  }
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
              )),
            ),
          );
        });
  }
}
