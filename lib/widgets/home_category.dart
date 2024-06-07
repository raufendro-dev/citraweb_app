// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mikrotik/screens/product_by_category_screen.dart';

import '../constant/config.dart';

class HomeCategroy extends StatelessWidget {
  HomeCategroy({Key? key}) : super(key: key);

  late final Future<List<Map<String, dynamic>>> futureCategory =
      fetchCategory();

  Future<List<Map<String, dynamic>>> fetchCategory({int delay = 0}) async {
    return Future.delayed(Duration(seconds: delay), () async {
      final List<Map<String, dynamic>> listCategory = [];

      final responseCategory = await http.get(Uri.parse(Config.baseUrlApi +
          'app-api/produk/kategori/?key=0cc7da679bea04fea453c8062e06514d'));
      if (responseCategory.statusCode == 200) {
        final Map customCategory = jsonDecode(responseCategory.body);
        if (customCategory['data'].isNotEmpty) {
          for (var categoryItem in customCategory['data']) {
            listCategory.add(categoryItem);
          }
        }
      } else {
        print('Failed to load List Category');
      }
      return listCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build home category');
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCategory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var listCategory = snapshot.data;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                      (listCategory!.length / 2).ceil(),
                      (index) => SizedBox(
                            width: 72,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        _createRoute(ProductByCategoryScreen(
                                      idKategori: int.parse(
                                          listCategory[index * 2]['id']),
                                      namaKategori: listCategory[index * 2]
                                          ['nama'],
                                    )));
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        child: listCategory[index * 2]
                                                    ['image'] ==
                                                ""
                                            ? Container()
                                            : AspectRatio(
                                                aspectRatio: 1,
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      listCategory[index * 2]
                                                          ['image'],
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  )),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                      ),
                                      SizedBox(
                                        height: 24,
                                        child: Text(
                                          listCategory[index * 2]['nama'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (index * 2 + 1 < listCategory.length)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          _createRoute(ProductByCategoryScreen(
                                        idKategori: int.parse(
                                            listCategory[index * 2 + 1]['id']),
                                        namaKategori:
                                            listCategory[index * 2 + 1]['nama'],
                                      )));
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  listCategory[index * 2 + 1]
                                                      ['image'],
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
                                        SizedBox(
                                          height: 24,
                                          child: Text(
                                            listCategory[index * 2 + 1]['nama'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption!
                                                .copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onBackground,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            ),
                          )),
                ),
              ),
            );
          }
          return const Text('Load Category ...');
        });
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
}
