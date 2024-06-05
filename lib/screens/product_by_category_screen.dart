// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/main.dart';
import 'package:mikrotik/screens/detail_product_screen.dart';
import 'package:mikrotik/widgets/app_bar_home.dart';
import 'package:http/http.dart' as http;
import 'package:mikrotik/widgets/end_drawer_home.dart';
import 'package:mikrotik/widgets/shimmer_widget.dart';

class ProductByCategoryScreen extends StatefulWidget {
  const ProductByCategoryScreen(
      {Key? key, required this.idKategori, this.namaKategori = ''})
      : super(key: key);

  final int idKategori;
  final String namaKategori;

  @override
  State<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {
  Future<List<Map<String, dynamic>>>? futureProdukLainnya;

  int curentPage = 1;
  int totalPage = 1;

  Future<List<Map<String, dynamic>>> fetchProdukLainnya(int id,
      {bool loadMore = false, List listLama = const []}) async {
    final page = loadMore ? '&page=${curentPage + 1}' : '&page=$curentPage';
    final List<Map<String, dynamic>> listProdukLain = [];

    final responseProdukLain = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/produk/wherekategori/?id=$id&key=0cc7da679bea04fea453c8062e06514d$page'));
    if (responseProdukLain.statusCode == 200) {
      final Map produkLain = jsonDecode(responseProdukLain.body);
      if (produkLain['data'].isNotEmpty) {
        for (var infoItem in produkLain['data']) {
          listProdukLain.add(infoItem);
        }
        print(produkLain['totalpage'].toString() + ' page');
        if (loadMore) {
          setState(() {
            curentPage += 1;
            totalPage = produkLain['totalpage'];
          });
        } else {
          setState(() {
            totalPage = produkLain['totalpage'];
          });
        }
      }
    } else {
      print('Failed to load Produk Lainnya');
      print(
          'app-api/produk/wherekategori/?id=$id&key=0cc7da679bea04fea453c8062e06514d');
    }

    if (loadMore) {
      print('loadMore');
      return (listLama as List<Map<String, dynamic>>) + listProdukLain;
    } else {
      print('first load');
      // print(listProdukLain);
      return listProdukLain;
    }
  }

  @override
  void initState() {
    super.initState();
    futureProdukLainnya = fetchProdukLainnya(widget.idKategori);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHome(
        leading: Leading.back,
        hint: widget.namaKategori,
      ),
      endDrawer: const EndDrawerHome(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureProdukLainnya,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (ScrollEndNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      if (curentPage < totalPage) {
                        setState(() {
                          futureProdukLainnya = fetchProdukLainnya(
                            widget.idKategori,
                            loadMore: true,
                            listLama: snapshot.data!,
                          );
                        });
                      }
                      print(curentPage);
                      return true;
                    } else {
                      return false;
                    }
                  },
                  child: GridView.count(
                    primary: false,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    // controller: _gridviewcontroller,
                    crossAxisCount: 2,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    childAspectRatio: 3 / 4.1,
                    children: List.generate(
                      curentPage < totalPage
                          ? snapshot.data!.length + 2
                          : snapshot.data!.length,
                      (index) {
                        return curentPage < totalPage &&
                                index + 1 > snapshot.data!.length
                            ? Card(
                                elevation: 4,
                                child: Container(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ShimmerWidget.rectangular(
                                            height: double.infinity),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 8, 8, 6),
                                        child: ShimmerWidget.rectangular(
                                            height: 12),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: ShimmerWidget.rectangular(
                                            height: 8),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 8, 8, 0),
                                        child: ShimmerWidget.rectangular(
                                            width: 120, height: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(_createRoute(
                                      DetailProductScreen(
                                        productId: int.parse(
                                            snapshot.data![index]['id']),
                                      ),
                                      slideDirection.toLeft));
                                  // Navigator.push(
                                  //     context,
                                  //     EnterExitRoute(
                                  //         exitPage: widget,
                                  //         enterPage:
                                  //             DetailProductScreen(
                                  //           productId: int.parse(
                                  //               snapshot.data![index]
                                  //                   ['id']),
                                  //         )));
                                },
                                child: Card(
                                  clipBehavior: Clip.hardEdge,
                                  elevation: 4,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Stack(children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: CachedNetworkImage(
                                              imageUrl: Config().mktToCst(
                                                  snapshot.data![index]
                                                      ['gambar_kecil']),
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                strokeWidth: 2,
                                              )),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        if (snapshot.data![index]
                                                ['status_barang'] ==
                                            'HABIS')
                                          Positioned(
                                            top: 2,
                                            right: 1,
                                            child: Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              child: Text(
                                                snapshot.data![index]
                                                    ['status_barang'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onError),
                                              ),
                                            ),
                                          )
                                      ]),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              snapshot.data![index]
                                                  ['nama_kategori'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              snapshot.data![index]['nama'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              snapshot.data![index]['harga_rp']
                                                  .replaceAll(',00', ''),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                      },
                    ),
                  ),
                ),
              );
            }
            return const Center(
                child: CircularProgressIndicator(
              strokeWidth: 2,
            ));
          }),
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
