// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mikrotik/widgets/shimmer_widget.dart';
import 'dart:convert';

import '../constant/config.dart';
import '../screens/detail_product_screen.dart';
import '../models/banner_model.dart';
import '../widgets/home_slider.dart';

class ContentProduk extends StatefulWidget {
  const ContentProduk({Key? key}) : super(key: key);

  @override
  State<ContentProduk> createState() => _ContentProdukState();
}

class _ContentProdukState extends State<ContentProduk>
    with AutomaticKeepAliveClientMixin<ContentProduk> {
  late Future<List<BannerModel>> futureBanner;
  Future<List<Map<String, dynamic>>>? futureProduk;

  final CarouselController _controllerBanner = CarouselController();

  int curentPage = 1;
  int totalPage = 1;

  Future<List<BannerModel>> fetchBanner() async {
    final List<BannerModel> listBanner = [];

    final responseBanner = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/depan/banner/?key=0cc7da679bea04fea453c8062e06514d'));
    if (responseBanner.statusCode == 200) {
      print('fetchBanner');
      final Map banner = jsonDecode(responseBanner.body);
      if (banner['data'].isNotEmpty) {
        for (var bannerItem in banner['data']) {
          listBanner.add(BannerModel.fromJson(bannerItem));
        }
      }
    } else {
      print('Failed to load Banner');
    }
    return listBanner;
  }

  Future<List<Map<String, dynamic>>> fetchProduk(
      {bool loadMore = false, List listLama = const []}) async {
    final page = loadMore ? '&page=${curentPage + 1}' : '&page=$curentPage';
    final List<Map<String, dynamic>> listProduk = [];

    final responseProduk = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/produk/?key=0cc7da679bea04fea453c8062e06514d$page'));
    print("rauf");
    print(Config.baseUrlApi.toString() +
        'app-api/produk/?key=0cc7da679bea04fea453c8062e06514d' +
        page);
    if (responseProduk.statusCode == 200) {
      print('fetchProduk');
      final Map produk = jsonDecode(responseProduk.body);
      if (produk['data'].isNotEmpty) {
        for (var infoItem in produk['data']) {
          listProduk.add(infoItem);
        }

        print(produk['totalpage'].toString() + ' page');
        if (loadMore) {
          setState(() {
            curentPage += 1;
            totalPage = produk['totalpage'];
          });
        } else {
          setState(() {
            totalPage = produk['totalpage'];
          });
        }
      }
    } else {
      print('Failed to load Produk Baru');
    }

    if (loadMore) {
      print('loadMore');
      return (listLama as List<Map<String, dynamic>>) + listProduk;
    } else {
      print('first load');
      // print(listProduk);
      return listProduk;
    }
  }

  var cekscroll = false;

  @override
  void initState() {
    super.initState();
    futureBanner = fetchBanner();
    futureProduk = fetchProduk();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build produk');
    return RefreshIndicator(
      displacement: 100,
      onRefresh: _refresh,
      child: Column(
        children: [
          // cekscroll == false
          //     ?
          // HomeSilder(futureBanner: futureBanner, controller: _controllerBanner),
          //     : Container(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: futureProduk,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return NotificationListener<ScrollEndNotification>(
                      // return NotificationListener<ScrollNotification>(
                      //   onNotification: (notification) {
                      //     if (notification is ScrollStartNotification) {
                      //       // Handle scroll start
                      //       print('Scroll started');
                      //     } else if (notification is ScrollUpdateNotification) {
                      //       // Handle scroll update
                      //       print('Scroll updated');
                      //       if (notification.metrics.pixels <=
                      //           notification.metrics.minScrollExtent) {
                      //         setState(() {
                      //           cekscroll = false;
                      //         });
                      //       } else {
                      //         setState(() {
                      //           cekscroll = true;
                      //         });
                      //       }
                      //     } else if (notification is ScrollEndNotification) {
                      //       // Handle scroll end
                      //       print('Scroll ended');
                      //       if (notification.metrics.pixels ==
                      //           notification.metrics.maxScrollExtent) {
                      //         if (curentPage < totalPage) {
                      //           setState(() {
                      //             futureProduk = fetchProduk(
                      //               loadMore: true,
                      //               listLama: snapshot.data!,
                      //             );
                      //           });
                      //         }
                      //         print(curentPage);
                      //         return true;
                      //       } else {
                      //         return false;
                      //       }
                      //     }
                      //     return true;
                      //   },
                      onNotification: (ScrollEndNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                          if (curentPage < totalPage) {
                            setState(() {
                              futureProduk = fetchProduk(
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
                        // shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        crossAxisCount: 2,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3,
                        childAspectRatio: 3 / 4,
                        children: List.generate(
                            curentPage < totalPage
                                ? snapshot.data!.length + 2
                                : snapshot.data!.length, (index) {
                          return curentPage < totalPage &&
                                  index + 1 > snapshot.data!.length
                              ? Card(
                                  elevation: 4,
                                  child: Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
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
                                    Navigator.of(context)
                                        .push(_createRoute(DetailProductScreen(
                                      productId: int.parse(
                                          snapshot.data![index]['id']),
                                    )));
                                    // CupertinoPageRoute(
                                    //     builder: (_) => DetailProductScreen(
                                    //         productId: int.parse(snapshot.data![index]['id'])));
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
                                            ),
                                          if (snapshot.data![index]
                                                  ['status_barang'] ==
                                              'INDEN')
                                            Positioned(
                                              top: 2,
                                              right: 1,
                                              child: Container(
                                                color: Colors.blue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2),
                                                child: Text(
                                                  "PRE ORDER",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onError),
                                                ),
                                              ),
                                            ),
                                          if (snapshot.data![index]
                                                  ['status_barang'] ==
                                              "CALL TO BUY")
                                            Positioned(
                                              top: 2,
                                              right: 1,
                                              child: Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2),
                                                child: Text(
                                                  "Call to buy",
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
                                              horizontal: 8.0, vertical: 3),
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
                                              snapshot.data![index]
                                                          ['harga_rp'] !=
                                                      "0"
                                                  ? Text(
                                                      snapshot.data![index]
                                                              ['harga_rp']
                                                          .replaceAll(
                                                              ',00', ''),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        }),
                      ),
                    );
                  }

                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    children: List.generate(6, (index) {
                      return Card(
                        // color: Theme.of(context).colorScheme.background,
                        child: Center(
                            child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      futureBanner = fetchBanner();
      curentPage = 1;
      totalPage = 1;
      futureProduk = fetchProduk();
    });
    return Future.delayed(const Duration(seconds: 1));
  }

  Route _createRoute(page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.linear;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
