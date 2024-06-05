// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/screens/detail_product_screen.dart';
import 'package:mikrotik/screens/product_by_category_screen.dart';
import 'package:mikrotik/widgets/home_category.dart';

class CustomSearchDelegate extends SearchDelegate {
  List kategori = [];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            if (query.isNotEmpty) {
              query = '';
              showSuggestions(context);
            } else {
              close(context, null);
            }
          },
          icon: const Icon(Icons.close))
    ];
    // throw UnimplementedError();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      colorScheme: Theme.of(context).colorScheme,
      hintColor: Theme.of(context).colorScheme.onBackground.withAlpha(170),
      textSelectionTheme: TextSelectionThemeData(
          cursorColor:
              Theme.of(context).colorScheme.onBackground.withAlpha(170)),
      inputDecorationTheme: InputDecorationTheme(
        constraints: const BoxConstraints(maxHeight: 40),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(22.0)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(22.0)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          //  when the TextFormField in unfocused
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(22.0)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          //  when the TextFormField in focused
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        isDense: false,
        hintStyle: const TextStyle(height: 1.5),
      ),
      appBarTheme: AppBarTheme(
        titleSpacing: 0,
        color: Theme.of(context)
            .colorScheme
            .primary, // affects AppBar's background color
        // hintColor: Colors.grey, // affects the initial 'Search' text
        toolbarTextStyle: const TextStyle(
            // headline 6 affects the query text
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return const BackButton();
    // throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {
    print('pageview');
    return PageView(children: [ResultPage(query: query)]);
    // throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    print(kategori);
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: HomeCategroy().fetchCategory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final kategori = snapshot.data!
                .where((element) => element['nama']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
                .toList();

            print(kategori);
            return ListView.builder(
              itemCount: kategori.length,
              itemBuilder: (contex, index) {
                return ListTile(
                  title: Text(kategori[index]['nama']),
                  onTap: () {
                    // query = 'Kategori ' + kategori[index]['nama'];
                    // showResults(context);
                    close(context, null);

                    Navigator.of(context)
                        .push(_createRoute(ProductByCategoryScreen(
                      idKategori: int.parse(kategori[index]['id']),
                      namaKategori: kategori[index]['nama'],
                    )));
                  },
                  dense: true,
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    // throw UnimplementedError();
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

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key, required this.query}) : super(key: key);
  final String query;

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with AutomaticKeepAliveClientMixin<ResultPage> {
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

  Future<List<Map<String, dynamic>>> fetchSearchProduk(String query) async {
    final List<Map<String, dynamic>> listProduk = [];

    final responseProduk = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/produk/search/?search=$query&key=0cc7da679bea04fea453c8062e06514d'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/produk/search/?search=$query&key=0cc7da679bea04fea453c8062e06514d'));
    if (responseProduk.statusCode == 200) {
      print('fetchSearchProduk');
      final Map produk = jsonDecode(responseProduk.body);
      if (produk['data'].isNotEmpty) {
        for (var infoItem in produk['data']) {
          listProduk.add(infoItem);
        }
      }
    } else {
      print('Failed to load Produk Baru');
    }
    return listProduk;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<Map>>(
        future: fetchSearchProduk(widget.query),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final listProduk = snapshot.data!;

            if (listProduk.isEmpty) {
              return const Center(child: Text('Produk tidak ditemukan.'));
            }

            return GridView.count(
              // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //   crossAxisCount: 2,
              // ),
              // itemCount: listProduk.length,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 3 / 4,
              crossAxisCount: 2,
              children: List.generate(
                listProduk.length,
                (index) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(_createRoute(DetailProductScreen(
                      productId: int.parse(listProduk[index]['id']),
                    )));
                    // CupertinoPageRoute(
                    //     builder: (_) => DetailProductScreen(
                    //         productId: int.parse(listProduk[index]['id'])));
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
                                    listProduk[index]['gambar_kecil']),
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                )),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                          if (listProduk[index]['status_barang'] == 'HABIS')
                            Positioned(
                              top: 2,
                              right: 1,
                              child: Container(
                                color: Theme.of(context).colorScheme.error,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  listProduk[index]['status_barang'],
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                listProduk[index]['nama_kategori'],
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
                                listProduk[index]['nama'],
                                style: Theme.of(context).textTheme.bodyText2,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                listProduk[index]['harga_rp']
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
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}
