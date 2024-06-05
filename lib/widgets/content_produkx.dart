// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    with
        // AutomaticKeepAliveClientMixin<ContentProduk>,
        TickerProviderStateMixin {
  late Future<List<BannerModel>> futureBanner;
  late final Future<List<Map<String, dynamic>>> futureProduk;

  final int _selectedTab = 0;
  final CarouselController _controllerBanner = CarouselController();
  late PageController _pageProdukParentController;
  late PageController _pageProdukController;
  late TabController _tabController;
  // late ScrollController _gridviewcontroller;

  final List<Map> tabProduk = [
    {'text': 'Semua', 'url': ''},
    {'text': 'Terbaru', 'url': ''},
    {'text': 'Unggulan', 'url': ''},
    {'text': 'Harga', 'url': ''}
  ];

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

  Future<List<Map<String, dynamic>>> fetchProduk() async {
    final List<Map<String, dynamic>> listProduk = [];

    final responseProduk = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/produk/?key=0cc7da679bea04fea453c8062e06514d'));
    if (responseProduk.statusCode == 200) {
      print('fetchProduk');
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
  void initState() {
    super.initState();
    futureBanner = fetchBanner();
    futureProduk = fetchProduk();

    _pageProdukController = PageController(initialPage: 0);
    _pageProdukParentController = PageController();
    _tabController = TabController(vsync: this, length: tabProduk.length);

    // _gridviewcontroller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    print('build produk');
    return RefreshIndicator(
      displacement: 100,
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _pageProdukParentController,
        slivers: [
          SliverToBoxAdapter(
            child: HomeSilder(
                futureBanner: futureBanner, controller: _controllerBanner),
          ),
          SliverAppBar(
            primary: true,
            pinned: true,
            backgroundColor: Colors.grey[100],
            // shadowColor: Colors.white,
            title: DefaultTabController(
              length: 4, // length of tabs
              initialIndex: _selectedTab,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    onTap: (index) {
                      print('tab $index');
                      _pageProdukController.animateToPage(index,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.linear);
                    },
                    automaticIndicatorColorAdjustment: false,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).colorScheme.primary),
                    indicatorColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.background,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 0,
                    unselectedLabelColor: Theme.of(context).colorScheme.primary,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    tabs: tabProduk
                        .map(
                          (tab) => Tab(
                            height: 36,
                            // text: tab['text'],
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 1)),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tab['text'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: PageView(
                onPageChanged: (index) async {
                  print('slide tab $index');

                  if (!_tabController.indexIsChanging) {
                    print('ok');
                    _tabController.animateTo(index,
                        duration:
                            const Duration(milliseconds: 100)); // Switch tabs
                  }
                },
                controller: _pageProdukController,
                children: tabProduk
                    .map(
                      (e) => ContentProdukTab(
                          key: PageStorageKey('gridProduk$e'),
                          // gridviewcontroller: _gridviewcontroller,
                          pageProdukParentController:
                              _pageProdukParentController,
                          futureProduk: futureProduk),
                    )
                    .toList(),
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
    });
    return Future.delayed(const Duration(seconds: 1));
  }

  // @override
  // bool get wantKeepAlive => true;
}

class ContentProdukTab extends StatefulWidget {
  const ContentProdukTab({
    Key? key,
    // required ScrollController gridviewcontroller,
    required PageController pageProdukParentController,
    required this.futureProduk,
  })  : _pageProdukParentController = pageProdukParentController,
        super(key: key);

  final Future<List<Map<String, dynamic>>> futureProduk;
  final PageController _pageProdukParentController;

  @override
  State<ContentProdukTab> createState() => _ContentProdukTabState();
}

class _ContentProdukTabState extends State<ContentProdukTab>
    with AutomaticKeepAliveClientMixin<ContentProdukTab> {
  late ScrollController _gridviewcontroller;
  final _config = Config();

  @override
  void initState() {
    super.initState();

    _gridviewcontroller = ScrollController();
    _gridviewcontroller.addListener(() {
      if (_gridviewcontroller.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (widget._pageProdukParentController.offset != 0 &&
            _gridviewcontroller.offset == 0) {
          widget._pageProdukParentController.animateTo(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        }
      } else if (_gridviewcontroller.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (widget._pageProdukParentController.offset !=
            widget._pageProdukParentController.position.maxScrollExtent) {
          widget._pageProdukParentController.animateTo(
              widget._pageProdukParentController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build content produk tab');
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: widget.key,
      future: widget.futureProduk,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // snapshot.data!.shuffle();
          return GridView.count(
            padding: const EdgeInsets.only(bottom: 8),
            controller: _gridviewcontroller,
            crossAxisCount: 2,
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
            childAspectRatio: 3 / 4,
            children: List.generate(snapshot.data!.length, (index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(_createRoute(DetailProductScreen(
                    productId: int.parse(snapshot.data![index]['id']),
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
                              imageUrl: _config.mktToCst(
                                  snapshot.data![index]['gambar_kecil']),
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                strokeWidth: 2,
                              )),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                        if (snapshot.data![index]['status_barang'] == 'HABIS')
                          Positioned(
                            top: 2,
                            right: 1,
                            child: Container(
                              color: Theme.of(context).colorScheme.error,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                snapshot.data![index]['status_barang'],
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onError),
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
                              snapshot.data![index]['nama_kategori'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              snapshot.data![index]['nama'],
                              style: Theme.of(context).textTheme.bodyText2,
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
                                      color:
                                          Theme.of(context).colorScheme.error),
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
            }),
          );
        }

        return GridView.count(
          controller: _gridviewcontroller,
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
    );
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
