// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constant/config.dart';
import '../screens/detail_product_screen.dart';
// import '../widgets/placeholder_produk_carousel.dart';

class HomeProdukUnggulan extends StatelessWidget {
  HomeProdukUnggulan(
      {Key? key, required this.futureProdukUnggulan, required this.createRoute})
      : super(key: key);

  final Future<List<Map<String, dynamic>>>? futureProdukUnggulan;
  final Function createRoute;
  final _config = Config();

  @override
  Widget build(BuildContext context) {
    print('build home produk unggulan');
    // return FutureBuilder<List<Map<String, dynamic>>>(
    //   future: futureProdukUnggulan,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       return Container(
    //         width: double.infinity,
    //         // height: 220,
    //         color: Theme.of(context).colorScheme.background,
    //         margin: const EdgeInsets.symmetric(vertical: 8),
    //         child: Padding(
    //           padding: const EdgeInsets.symmetric(
    //             vertical: 6,
    //           ),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Padding(
    //                 padding: const EdgeInsets.fromLTRB(
    //                   8,
    //                   4,
    //                   8,
    //                   4,
    //                 ),
    //                 child: Text(
    //                   'Produk Unggulan',
    //                   style: Theme.of(context)
    //                       .textTheme
    //                       .bodyText1!
    //                       .copyWith(color: Theme.of(context).primaryColor),
    //                 ),
    //               ),
    //               SingleChildScrollView(
    //                 scrollDirection: Axis.horizontal,
    //                 child: IntrinsicHeight(
    //                   child: Row(children: [
    //                     ...snapshot.data!.map((idx) {
    //                       return Container(
    //                         width: 120,
    //                         margin: const EdgeInsets.only(
    //                           bottom: 4,
    //                         ),
    //                         alignment: Alignment.center,
    //                         child: GestureDetector(
    //                           onTap: () {
    //                             Navigator.of(context)
    //                                 .push(createRoute(DetailProductScreen(
    //                               productId: int.parse(idx['id']),
    //                             )));
    //                           },
    //                           child: Card(
    //                             clipBehavior: Clip.hardEdge,
    //                             elevation: 4,
    //                             child: Column(
    //                               mainAxisSize: MainAxisSize.max,
    //                               children: [
    //                                 Stack(children: [
    //                                   SizedBox(
    //                                     width: double.infinity,
    //                                     child: AspectRatio(
    //                                       aspectRatio: 1,
    //                                       child: CachedNetworkImage(
    //                                         imageUrl: _config
    //                                             .mktToCst(idx['gambar_kecil']),
    //                                         placeholder: (context, url) =>
    //                                             const Center(
    //                                                 child:
    //                                                     CircularProgressIndicator(
    //                                           strokeWidth: 2,
    //                                         )),
    //                                         errorWidget:
    //                                             (context, url, error) =>
    //                                                 const Icon(Icons.error),
    //                                       ),
    //                                     ),
    //                                   ),
    //                                   if (idx['status_barang'] == 'HABIS')
    //                                     Positioned(
    //                                       top: 2,
    //                                       right: 1,
    //                                       child: Container(
    //                                         color: Theme.of(context)
    //                                             .colorScheme
    //                                             .error,
    //                                         padding: const EdgeInsets.symmetric(
    //                                             horizontal: 2),
    //                                         child: Text(
    //                                           idx['status_barang'],
    //                                           style: TextStyle(
    //                                               color: Theme.of(context)
    //                                                   .colorScheme
    //                                                   .onError),
    //                                         ),
    //                                       ),
    //                                     )
    //                                 ]),
    //                                 Padding(
    //                                   padding: const EdgeInsets.symmetric(
    //                                       horizontal: 8.0, vertical: 4),
    //                                   child: Column(
    //                                     crossAxisAlignment:
    //                                         CrossAxisAlignment.stretch,
    //                                     children: [
    //                                       Text(
    //                                         idx['nama'],
    //                                         style: Theme.of(context)
    //                                             .textTheme
    //                                             .caption,
    //                                         overflow: TextOverflow.ellipsis,
    //                                         maxLines: 2,
    //                                       ),
    //                                       const SizedBox(
    //                                         height: 4,
    //                                       ),
    //                                       Text(
    //                                         idx['harga_rp']
    //                                             .replaceAll(',00', ''),
    //                                         style: Theme.of(context)
    //                                             .textTheme
    //                                             .bodyText2!
    //                                             .copyWith(
    //                                                 color: Theme.of(context)
    //                                                     .primaryColor),
    //                                         overflow: TextOverflow.ellipsis,
    //                                         maxLines: 1,
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                         ),
    //                       );
    //                     })
    //                   ]),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       );
    //     }
    //     // else if (snapshot.hasError) {
    //     //   return Text('${snapshot.error}');
    //     // }

    //     // By default, show a loading spinner.
    //     // return const SizedBox(
    //     //   width: double.infinity,
    //     //   height: 100,
    //     //   child: Center(
    //     //       child: CircularProgressIndicator(
    //     //     strokeWidth: 2,
    //     //   )),
    //     // );
    //     return const PlaceholderProdukCarousel();
    //   },
    // );

    return FutureBuilder<List<Map<String, dynamic>>>(
        future: futureProdukUnggulan,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 2, 6, 2),
                  color: const Color(0xFF505BA8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 40,
                        alignment: Alignment.centerLeft,
                        child: Text('PRODUK UNGGULAN',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background)),
                      ),
                      // SizedBox(
                      //   height: 40,
                      //   child: Directionality(
                      //     textDirection: TextDirection.rtl,
                      //     child: TextButton.icon(
                      //       style: TextButton.styleFrom(
                      //           padding: EdgeInsets.zero,
                      //           primary:
                      //               Theme.of(context).colorScheme.background,
                      //           alignment: Alignment.center),
                      //       label: const Text(
                      //         'Selengkapnya',
                      //         style: TextStyle(fontWeight: FontWeight.normal),
                      //       ),
                      //       icon: Container(
                      //           padding: EdgeInsets.zero,
                      //           width: 14,
                      //           child: const Icon(Icons.keyboard_arrow_right)),
                      //       onPressed: () {},
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                      // snapshot.data!.length > 6 ? 6 : snapshot.data!.length,
                      snapshot.data!.length,
                      (index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(createRoute(DetailProductScreen(
                              productId: int.parse(snapshot.data![index]['id']),
                            )));
                            // Navigator.of(context).push(
                            //     _createRoute(DetailProductScreen(
                            //   productId: int.parse(
                            //       snapshot.data![index]['id']),
                            // )));
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
                                        imageUrl: _config.mktToCst(snapshot
                                            .data![index]['gambar_kecil']),
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator(
                                          strokeWidth: 2,
                                        )),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  if (snapshot.data![index]['status_barang'] ==
                                      'HABIS')
                                    Positioned(
                                      top: 2,
                                      right: 1,
                                      child: Container(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        padding: const EdgeInsets.symmetric(
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
                                  if (snapshot.data![index]['status_barang'] ==
                                      'INDEN')
                                    Positioned(
                                      top: 2,
                                      right: 1,
                                      child: Container(
                                        color: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
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
                                  if (snapshot.data![index]['status_barang'] ==
                                      'CALL TO BUY')
                                    Positioned(
                                      top: 2,
                                      right: 1,
                                      child: Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        padding: const EdgeInsets.symmetric(
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
                                        snapshot.data![index]['nama_kategori'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.w600),
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
                                      snapshot.data![index]['harga_rp'] != "0"
                                          ? Text(
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
                                            )
                                          : Container()
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
              ],
            );
          }
          return const Center(
              child: CircularProgressIndicator(
            strokeWidth: 2,
          ));
        });
  }
}
