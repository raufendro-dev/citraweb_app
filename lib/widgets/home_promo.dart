// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mikrotik/services/auth_service.dart';

import '../constant/config.dart';
import '../screens/detail_product_screen.dart';
import '../widgets/placeholder_produk_carousel.dart';

class HomePromo extends StatefulWidget {
  HomePromo({Key? key, required this.futurePromo, required this.createRoute})
      : super(key: key);

  final Future<List<Map<String, dynamic>>>? futurePromo;
  final Function createRoute;

  @override
  State<HomePromo> createState() => _HomePromoState();
}

class _HomePromoState extends State<HomePromo> {
  final _config = Config();

  bool sudahLogin = false;
  cekLogin() async {
    AuthService().cekLogin(context).then((value) async {
      if (value) {
        setState(() {
          sudahLogin = value;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    cekLogin();
  }

  @override
  Widget build(BuildContext context) {
    print('build home promo');
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.futurePromo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: snapshot.data!
                .map(
                  (e) => Container(
                    width: double.infinity,
                    // height: 220,
                    color: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.only(top: 6, bottom: 18),
                    margin: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            8,
                            10,
                            8,
                            12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e['judul_promosi'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Periode Promo: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryVariant,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    child: Text(
                                      e['start_promosi'] +
                                          ' - ' +
                                          e['end_promosi'],
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                          fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Html(
                                data: e['keterangan_promosi'],
                                style: {
                                  "*": Style(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    margin: EdgeInsets.zero,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    fontSize: const FontSize(12),
                                  ),
                                },
                              ),
                              // Html(
                              //   data: e['update_promosi'],
                              //   style: {
                              //     "*": Style(
                              //       padding: EdgeInsets.zero,
                              //       margin: EdgeInsets.zero,
                              //       color: Theme.of(context)
                              //           .colorScheme
                              //           .background,
                              //       fontSize: const FontSize(12),
                              //     ),
                              //   },
                              // ),
                            ],
                          ),
                        ),
                        CarouselSlider(
                          items: [
                            ...e['produk'].map((produk) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      widget.createRoute(DetailProductScreen(
                                    productId: int.parse(produk['id']),
                                  )));
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                      ),
                                      // padding: EdgeInsets.all(4),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child:
                                                      produk['gambar_kecil'] !=
                                                              null
                                                          ? CachedNetworkImage(
                                                              imageUrl: _config
                                                                  .mktToCst(produk[
                                                                      'gambar_kecil']),
                                                              placeholder: (context,
                                                                      url) =>
                                                                  const Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              )),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(Icons
                                                                      .error),
                                                            )
                                                          : Container()),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  produk['nama'] != null
                                                      ? Text(
                                                          produk['nama'],
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyText2!
                                                              .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        )
                                                      : Container(),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    produk['kode'],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 2),
                                                    color: produk[
                                                                'app_txt_ganti_harga'] ==
                                                            "DISCONTINUED"
                                                        ? Colors.grey
                                                        : produk['app_txt_ganti_harga'] ==
                                                                "CALL TO BUY"
                                                            ? Colors.black
                                                            : produk['app_txt_ganti_harga'] ==
                                                                        "LOGIN TO CHECK PRICE" &&
                                                                    sudahLogin ==
                                                                        false
                                                                ? Colors.yellow
                                                                : Colors
                                                                    .transparent,
                                                    child: Text(
                                                      produk['app_txt_ganti_harga'] ==
                                                              ""
                                                          ? produk['harga_rp']
                                                          : produk['app_txt_ganti_harga'] ==
                                                                      "LOGIN TO CHECK PRICE" &&
                                                                  sudahLogin ==
                                                                      true
                                                              ? produk[
                                                                  'harga_rp']
                                                              : produk[
                                                                  'app_txt_ganti_harga'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2!
                                                          .copyWith(
                                                              color: produk[
                                                                          'app_txt_ganti_harga'] ==
                                                                      "DISCONTINUED"
                                                                  ? Colors.black
                                                                  : produk['app_txt_ganti_harga'] ==
                                                                          "CALL TO BUY"
                                                                      ? Colors
                                                                          .white
                                                                      : produk['app_txt_ganti_harga'] ==
                                                                              "LOGIN TO CHECK PRICE"
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .black),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      left: 12,
                                      child: Container(
                                        color: produk['app_kiri_atas'] == ""
                                            ? Colors.transparent
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Text(
                                          produk['app_kiri_atas'],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onError),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      left: 12,
                                      child: Container(
                                        color: produk['app_kiri_atas'] == ""
                                            ? Colors.transparent
                                            : Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Text(
                                          produk['app_kiri_atas'],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onError),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 6,
                                      left: 12,
                                      child: Container(
                                        color: produk['app_kiri_bawah'] ==
                                                "OUT OF STOCK"
                                            ? Colors.orange
                                            : produk['app_kiri_bawah'] ==
                                                    "PRE ORDER"
                                                ? Colors.green
                                                : Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Text(
                                          produk['app_kiri_bawah'],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onError),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 12,
                                      child: Container(
                                        color: produk['app_kanan_atas'] == ""
                                            ? Colors.transparent
                                            : Colors.orange,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Text(
                                          produk['app_kanan_atas'],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onError),
                                        ),
                                      ),
                                    ),

                                    // if (produk['status_barang'] == 'HABIS')
                                    //   Positioned(
                                    //     top: 6,
                                    //     left: 12,
                                    //     child: Container(
                                    //       color: Theme.of(context)
                                    //           .colorScheme
                                    //           .error,
                                    //       padding: const EdgeInsets.symmetric(
                                    //           horizontal: 2),
                                    //       child: Text(
                                    //         produk['status_barang'],
                                    //         style: TextStyle(
                                    //             color: Theme.of(context)
                                    //                 .colorScheme
                                    //                 .onError),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // if (produk['status_barang'] ==
                                    //     'CALL TO BUY')
                                    //   Positioned(
                                    //     top: 6,
                                    //     left: 12,
                                    //     child: Container(
                                    //       color: Theme.of(context)
                                    //           .colorScheme
                                    //           .primary,
                                    //       padding: const EdgeInsets.symmetric(
                                    //           horizontal: 2),
                                    //       child: Text(
                                    //         produk['status_barang'],
                                    //         style: TextStyle(
                                    //             color: Theme.of(context)
                                    //                 .colorScheme
                                    //                 .onError),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // if (produk['status_barang'] == 'IDEN')
                                    //   Positioned(
                                    //     top: 6,
                                    //     left: 12,
                                    //     child: Container(
                                    //       color: Colors.blue,
                                    //       padding: const EdgeInsets.symmetric(
                                    //           horizontal: 2),
                                    //       child: Text(
                                    //         produk['status_barang'],
                                    //         style: TextStyle(
                                    //             color: Theme.of(context)
                                    //                 .colorScheme
                                    //                 .onError),
                                    //       ),
                                    //     ),
                                    //   ),
                                  ],
                                ),
                              );
                            })
                          ],
                          options: CarouselOptions(
                            enableInfiniteScroll: false,
                            // autoPlay: true,
                            enlargeCenterPage: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            aspectRatio: 2.4,
                            viewportFraction: 0.87,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          );
        }
        return const PlaceholderProdukCarousel();
      },
    );
  }
}
