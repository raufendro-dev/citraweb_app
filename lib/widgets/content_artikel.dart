// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mikrotik/screens/detail_artikel_screen.dart';
import 'package:mikrotik/widgets/shimmer_widget.dart';
import 'dart:convert';

import '../constant/config.dart';

class ContentArtikel extends StatefulWidget {
  const ContentArtikel({Key? key}) : super(key: key);

  @override
  State<ContentArtikel> createState() => _ContentArtikelState();
}

class _ContentArtikelState extends State<ContentArtikel>
    with AutomaticKeepAliveClientMixin<ContentArtikel> {
  Future<List<Map<String, dynamic>>>? futureListArtikel;

  int curentPage = 1;
  int totalPage = 1;

  Future<List<Map<String, dynamic>>> fetchArtikel(
      {bool loadMore = false, List listLama = const []}) async {
    final page = loadMore ? '&page=${curentPage + 1}' : '&page=$curentPage';
    final List<Map<String, dynamic>> listArtikel = [];

    final responseArtikel = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/artikel/?key=0cc7da679bea04fea453c8062e06514d$page'));
    if (responseArtikel.statusCode == 200) {
      print('fetchArtikel');
      final Map artikel = jsonDecode(responseArtikel.body);
      if (artikel['data'].isNotEmpty) {
        for (var infoArtikel in artikel['data']) {
          listArtikel.add(infoArtikel);
        }
        print(artikel['totalpage'].toString() + ' page');
        if (loadMore) {
          setState(() {
            curentPage += 1;
            totalPage = artikel['totalpage'];
          });
        } else {
          setState(() {
            totalPage = artikel['totalpage'];
          });
        }
      }
    } else {
      print('Failed to load Produk Baru');
    }

    if (loadMore) {
      print('loadMore');
      return (listLama as List<Map<String, dynamic>>) + listArtikel;
    } else {
      print('first load');
      // print(listArtikel);
      return listArtikel;
    }
  }

  @override
  void initState() {
    super.initState();
    futureListArtikel = fetchArtikel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: futureListArtikel,
        // initialData: listArtikel,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final listArtikel = snapshot.data!;
            return NotificationListener<ScrollEndNotification>(
              onNotification: (ScrollEndNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  if (curentPage < totalPage) {
                    setState(() {
                      futureListArtikel = fetchArtikel(
                        loadMore: true,
                        listLama: listArtikel,
                      );
                    });
                  }
                  print(curentPage);
                  return true;
                } else {
                  return false;
                }
              },
              child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                        height: 0,
                      ),
                  itemCount: curentPage < totalPage
                      ? listArtikel.length + 1
                      : listArtikel.length,
                  itemBuilder: (context, index) {
                    return curentPage < totalPage &&
                            index + 1 > listArtikel.length
                        ? ListTile(
                            tileColor: Theme.of(context).colorScheme.background,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            title: const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: ShimmerWidget.rectangular(height: 14),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                ShimmerWidget.rectangular(
                                  height: 10,
                                  width: 125,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: ShimmerWidget.rectangular(
                                    height: 10,
                                    width: 110,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListTile(
                            tileColor: Theme.of(context).colorScheme.background,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailArtikelScreen(
                                    id: int.parse(listArtikel[index]['id']),
                                    // initialData: listArtikel[index],
                                  ),
                                ),
                              );
                            },
                            title: Text(listArtikel[index]['judul']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listArtikel[index]['nama_kategori']),
                                Text(listArtikel[index]['tanggal']),
                              ],
                            ),
                          );
                  }),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  @override
  bool get wantKeepAlive => true;
}
