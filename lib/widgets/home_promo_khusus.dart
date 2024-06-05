// ignore_for_file: avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constant/config.dart';
import '../screens/detail_product_screen.dart';
import '../widgets/placeholder_produk_carousel.dart';

class HomePromoKhusus extends StatelessWidget {
  HomePromoKhusus(
      {Key? key, required this.futurePromoKhusus, required this.createRoute})
      : super(key: key);

  final Future<List<Map<String, dynamic>>>? futurePromoKhusus;
  final Function createRoute;
  final _config = Config();

  @override
  Widget build(BuildContext context) {
    print('build home promo khusus');
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futurePromoKhusus,
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
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
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
                                e['judul_promosi_khusus'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background),
                              ),
                              const SizedBox(height: 4),
                              Html(
                                data: e['keterangan_promosi_khusus'],
                                style: {
                                  "*": Style(
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    fontSize: const FontSize(12),
                                  ),
                                },
                              ),
                            ],
                          ),
                        ),
                        CarouselSlider(
                          items: [
                            ...e['produk'].map((produk) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(createRoute(DetailProductScreen(
                                    productId: int.parse(produk['id']),
                                  )));
                                },
                                child: Stack(children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
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
                                                  BorderRadius.circular(8.0),
                                              child: CachedNetworkImage(
                                                imageUrl: _config.mktToCst(
                                                    produk['gambar_kecil']),
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
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  produk['nama'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2!
                                                      .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
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
                                                Text(
                                                  produk['harga_rp'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2!
                                                      .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (produk['status_barang'] == 'HABIS')
                                    Positioned(
                                      top: 6,
                                      left: 12,
                                      child: Container(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Text(
                                          produk['status_barang'],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onError),
                                        ),
                                      ),
                                    )
                                ]),
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
