// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constant/config.dart';
import '../screens/detail_product_screen.dart';

class HomeCustomCategory extends StatelessWidget {
  HomeCustomCategory({Key? key, required this.createRoute}) : super(key: key);
  final Function createRoute;

  final _config = Config();

  final List<Map<String, dynamic>> listCustomCategory =
      Config.listCustomCategory;

  Future<List<Map<String, dynamic>>> fetchCustomCategory(String api,
      {int delay = 0}) async {
    return Future.delayed(Duration(seconds: delay), () async {
      final List<Map<String, dynamic>> listCustomCategory = [];
      print(Uri.parse(Config.baseUrlApi + api));
      final responseCustomCategory =
          await http.get(Uri.parse(Config.baseUrlApi + api));
      if (responseCustomCategory.statusCode == 200) {
        final Map customCategory = jsonDecode(responseCustomCategory.body);
        if (customCategory['data'].isNotEmpty) {
          for (var infoItem in customCategory['data']) {
            listCustomCategory.add(infoItem);
          }
        }
      } else {
        print('Failed to load Promo Khusus');
      }
      return listCustomCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build home custom category');
    return Column(
      children: listCustomCategory.map((e) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchCustomCategory(e['api']),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var customCategory = snapshot.data!.first;
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                // child: Row(
                //   children: [
                //     Stack(
                //       children: [
                //         Container(
                //           width: MediaQuery.of(context).size.width / 3,
                //           color: Colors.white,
                //           child: AspectRatio(
                //             aspectRatio: 3 / 8.2,
                //             // child: Text(
                //             //   customCategory['judul'],
                //             //   style: Theme.of(context)
                //             //       .textTheme
                //             //       .bodyText1!
                //             //       .copyWith(
                //             //           color: Theme.of(context)
                //             //               .colorScheme
                //             //               .background),
                //             child: CachedNetworkImage(
                //                 imageUrl: customCategory['image_kategori']),
                //           ),
                //         ),
                //         Positioned(
                //           top: 0,
                //           left: 0,
                //           right: 0,
                //           bottom: 0,
                //           // child: ColorFiltered(
                //           //   colorFilter: const ColorFilter.mode(
                //           //       Colors.red, BlendMode.multiply),
                //           child: Container(
                //             width: double.infinity,
                //             height: double.infinity,
                //             padding: const EdgeInsets.all(14),
                //             // color: Colors.black87,
                //             decoration: BoxDecoration(
                //               color: Color(int.parse('0xEE${e['color']}')),
                //               backgroundBlendMode: BlendMode.multiply,
                //             ),
                //             child: Text(
                //               customCategory['judul'],
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .bodyText1!
                //                   .copyWith(
                //                       fontSize: 16,
                //                       fontWeight: FontWeight.w900,
                //                       color: Theme.of(context)
                //                           .colorScheme
                //                           .background),
                //             ),
                //           ),
                //           // ),
                //         ),
                //       ],
                //     ),
                //     Flexible(
                //       flex: 2,
                //       // Container(
                //       // width: MediaQuery.of(context).size.width / 3 * 2,
                //       // color: Colors.white,
                //       // child: AspectRatio(
                //       //   aspectRatio: 6 / 8,
                //       //   child: Text(
                //       //     customCategory['judul'],
                //       //     style: Theme.of(context)
                //       //         .textTheme
                //       //         .bodyText1!
                //       //         .copyWith(
                //       //             color:
                //       //                 Theme.of(context).colorScheme.background),
                //       //   ),
                //       // ),
                //       child: SingleChildScrollView(
                //         scrollDirection: Axis.horizontal,
                //         child: Row(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: List.generate(
                //             (customCategory['produk'].length / 2).ceil(),
                //             (index) => SizedBox(
                //               width: MediaQuery.of(context).size.width / 3,
                //               child: Column(
                //                 children: [
                //                   AspectRatio(
                //                     aspectRatio: 3 / 4.1,
                //                     child: Padding(
                //                       padding:
                //                           const EdgeInsets.fromLTRB(1, 0, 1, 1),
                //                       child: GestureDetector(
                //                         onTap: () {
                //                           Navigator.of(context).push(
                //                               createRoute(DetailProductScreen(
                //                             productId: int.parse(
                //                                 customCategory['produk']
                //                                     [index * 2]['id']),
                //                           )));
                //                         },
                //                         child: Stack(
                //                           children: [
                //                             Card(
                //                               shape:
                //                                   const RoundedRectangleBorder(
                //                                 borderRadius: BorderRadius.zero,
                //                               ),
                //                               margin: EdgeInsets.zero,
                //                               child: Padding(
                //                                 padding:
                //                                     const EdgeInsets.all(8.0),
                //                                 child: Column(
                //                                   crossAxisAlignment:
                //                                       CrossAxisAlignment.start,
                //                                   children: [
                //                                     AspectRatio(
                //                                       aspectRatio: 1,
                //                                       child: CachedNetworkImage(
                //                                         imageUrl: _config.mktToCst(
                //                                             customCategory[
                //                                                         'produk']
                //                                                     [index * 2][
                //                                                 'gambar_kecil']),
                //                                         placeholder: (context,
                //                                                 url) =>
                //                                             const Center(
                //                                                 child:
                //                                                     CircularProgressIndicator(
                //                                           strokeWidth: 2,
                //                                         )),
                //                                         errorWidget: (context,
                //                                                 url, error) =>
                //                                             const Icon(
                //                                                 Icons.error),
                //                                       ),
                //                                     ),
                //                                     Text(
                //                                       customCategory['produk']
                //                                           [index * 2]['nama'],
                //                                       style: Theme.of(context)
                //                                           .textTheme
                //                                           .caption,
                //                                       maxLines: 2,
                //                                       overflow:
                //                                           TextOverflow.ellipsis,
                //                                     ),
                //                                     Text(
                //                                       customCategory['produk']
                //                                                   [index * 2]
                //                                               ['harga_rp']
                //                                           .replaceAll(
                //                                               ',00', ''),
                //                                       style: Theme.of(context)
                //                                           .textTheme
                //                                           .bodyText2!
                //                                           .copyWith(
                //                                               color: Theme.of(
                //                                                       context)
                //                                                   .colorScheme
                //                                                   .error),
                //                                       maxLines: 1,
                //                                       overflow:
                //                                           TextOverflow.ellipsis,
                //                                     )
                //                                   ],
                //                                 ),
                //                               ),
                //                             ),
                //                             if (customCategory['produk']
                //                                         [index * 2]
                //                                     ['status_barang'] ==
                //                                 'HABIS')
                //                               Positioned(
                //                                 top: 2,
                //                                 right: 1,
                //                                 child: Container(
                //                                   color: Theme.of(context)
                //                                       .colorScheme
                //                                       .error,
                //                                   padding: const EdgeInsets
                //                                       .symmetric(horizontal: 2),
                //                                   child: Text(
                //                                     customCategory['produk']
                //                                             [index * 2]
                //                                         ['status_barang'],
                //                                     style: TextStyle(
                //                                         color: Theme.of(context)
                //                                             .colorScheme
                //                                             .onError),
                //                                   ),
                //                                 ),
                //                               ),
                //                           ],
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                   if (index * 2 + 1 <
                //                       customCategory['produk'].length)
                //                     AspectRatio(
                //                       aspectRatio: 3 / 4.1,
                //                       child: Padding(
                //                         padding: const EdgeInsets.fromLTRB(
                //                             1, 1, 1, 0),
                //                         child: GestureDetector(
                //                           onTap: () {
                //                             Navigator.of(context).push(
                //                                 createRoute(DetailProductScreen(
                //                               productId: int.parse(
                //                                   customCategory['produk']
                //                                       [index * 2 + 1]['id']),
                //                             )));
                //                           },
                //                           child: Stack(children: [
                //                             Card(
                //                               shape:
                //                                   const RoundedRectangleBorder(
                //                                 borderRadius: BorderRadius.zero,
                //                               ),
                //                               margin: EdgeInsets.zero,
                //                               child: Padding(
                //                                 padding:
                //                                     const EdgeInsets.all(8.0),
                //                                 child: Column(
                //                                   crossAxisAlignment:
                //                                       CrossAxisAlignment.start,
                //                                   children: [
                //                                     AspectRatio(
                //                                       aspectRatio: 1,
                //                                       child: CachedNetworkImage(
                //                                         imageUrl: _config.mktToCst(
                //                                             customCategory[
                //                                                         'produk']
                //                                                     [
                //                                                     index * 2 +
                //                                                         1][
                //                                                 'gambar_kecil']),
                //                                         placeholder: (context,
                //                                                 url) =>
                //                                             const Center(
                //                                                 child:
                //                                                     CircularProgressIndicator(
                //                                           strokeWidth: 2,
                //                                         )),
                //                                         errorWidget: (context,
                //                                                 url, error) =>
                //                                             const Icon(
                //                                                 Icons.error),
                //                                       ),
                //                                     ),
                //                                     Text(
                //                                       customCategory['produk']
                //                                               [index * 2 + 1]
                //                                           ['nama'],
                //                                       style: Theme.of(context)
                //                                           .textTheme
                //                                           .caption,
                //                                       maxLines: 2,
                //                                       overflow:
                //                                           TextOverflow.ellipsis,
                //                                     ),
                //                                     Text(
                //                                       customCategory['produk'][
                //                                                   index * 2 + 1]
                //                                               ['harga_rp']
                //                                           .replaceAll(
                //                                               ',00', ''),
                //                                       style: Theme.of(context)
                //                                           .textTheme
                //                                           .bodyText2!
                //                                           .copyWith(
                //                                               color: Theme.of(
                //                                                       context)
                //                                                   .colorScheme
                //                                                   .error),
                //                                       maxLines: 1,
                //                                       overflow:
                //                                           TextOverflow.ellipsis,
                //                                     )
                //                                   ],
                //                                 ),
                //                               ),
                //                             ),
                //                             if (customCategory['produk']
                //                                         [index * 2 + 1]
                //                                     ['status_barang'] ==
                //                                 'HABIS')
                //                               Positioned(
                //                                 top: 2,
                //                                 right: 1,
                //                                 child: Container(
                //                                   color: Theme.of(context)
                //                                       .colorScheme
                //                                       .error,
                //                                   padding: const EdgeInsets
                //                                       .symmetric(horizontal: 2),
                //                                   child: Text(
                //                                     customCategory['produk']
                //                                             [index * 2 + 1]
                //                                         ['status_barang'],
                //                                     style: TextStyle(
                //                                         color: Theme.of(context)
                //                                             .colorScheme
                //                                             .onError),
                //                                   ),
                //                                 ),
                //                               ),
                //                           ]),
                //                         ),
                //                       ),
                //                     ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                child: Column(
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
                            child: Text(customCategory['judul'],
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
                        childAspectRatio: 3 / 3.9,
                        children: List.generate(
                          // customCategory['produk'].length > 6 ? 6 : customCategory['produk'].length,
                          customCategory['produk'].length,
                          (index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(createRoute(DetailProductScreen(
                                  productId: int.parse(
                                      customCategory['produk'][index]['id']),
                                )));
                                // Navigator.of(context).push(
                                //     _createRoute(DetailProductScreen(
                                //   productId: int.parse(
                                //       customCategory['produk'][index]['id']),
                                // )));
                                // Navigator.push(
                                //     context,
                                //     EnterExitRoute(
                                //         exitPage: widget,
                                //         enterPage:
                                //             DetailProductScreen(
                                //           productId: int.parse(
                                //               customCategory['produk'][index]
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
                                            imageUrl: _config.mktToCst(
                                                customCategory['produk'][index]
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
                                      if (customCategory['produk'][index]
                                              ['status_barang'] ==
                                          'HABIS')
                                        Positioned(
                                          top: 2,
                                          right: 1,
                                          child: Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: Text(
                                              customCategory['produk'][index]
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
                                          // Text(
                                          //   customCategory['produk'][index]
                                          //       ['nama_kategori'],
                                          //   style: Theme.of(context)
                                          //       .textTheme
                                          //       .bodyText2!
                                          //       .copyWith(
                                          //           color:
                                          //               Theme.of(context)
                                          //                   .colorScheme
                                          //                   .primary,
                                          //           fontWeight:
                                          //               FontWeight.w600),
                                          //   overflow:
                                          //       TextOverflow.ellipsis,
                                          //   maxLines: 1,
                                          // ),
                                          Text(
                                            customCategory['produk'][index]
                                                ['nama'],
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
                                            customCategory['produk'][index]
                                                    ['harga_rp']
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
                  ],
                ),
              );
            }
            return Container(
              width: double.infinity,
              height: 300,
              margin: const EdgeInsets.only(bottom: 16),
              color: Color(int.parse('0xFF${e['color']}')),
              child: const Center(
                  child: CircularProgressIndicator(
                strokeWidth: 2,
              )),
            );
          },
        );
      }).toList(),
    );
  }
}
