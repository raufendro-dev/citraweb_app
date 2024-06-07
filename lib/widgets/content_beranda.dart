// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';

import '../constant/config.dart';
import '../models/banner_model.dart';
import 'home_slider.dart';
import 'home_category.dart';
import 'home_info.dart';
import 'home_promo.dart';
import 'home_promo_khusus.dart';
import 'home_produk_baru.dart';
import 'home_produk_unggulan.dart';
import 'home_custom_category.dart';

class ContentBeranda extends StatefulWidget {
  const ContentBeranda({Key? key}) : super(key: key);

  @override
  State<ContentBeranda> createState() => _ContentBerandaState();
}

class _ContentBerandaState extends State<ContentBeranda>
    with AutomaticKeepAliveClientMixin<ContentBeranda> {
  late Future<List<BannerModel>> futureBanner;
  late Future<List<String>> futureInfo;
  Future<List<Map<String, dynamic>>>? futurePromo;
  Future<List<Map<String, dynamic>>>? futurePromoKhusus;
  Future<List<Map<String, dynamic>>>? futureProdukBaru;
  Future<List<Map<String, dynamic>>>? futureProdukUnggulan;

  Future<List<BannerModel>> fetchBanner() async {
    final List<BannerModel> listBanner = [];

    final responseBanner = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/depan/banner/?key=0cc7da679bea04fea453c8062e06514d'));
    if (responseBanner.statusCode == 200) {
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

  Future<List<String>> fetchInfo() async {
    // return Future.delayed(const Duration(seconds: 1), () async {
    List<String> listInfo = [];

    final responseInfo = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/depan/?key=0cc7da679bea04fea453c8062e06514d'));
    if (responseInfo.statusCode == 200) {
      final Map info = jsonDecode(responseInfo.body);
      if (info['data'].isNotEmpty) {
        for (var infoItem in info['data']) {
          listInfo.add(infoItem['msg']);
        }
      }
      print("rauf tes1 ");
      print(responseInfo.body);
    } else {
      print("rauf tes2");
      print('Failed to load Info');
      return [];
    }
    return listInfo;
    // });
  }

  Future<List<Map<String, dynamic>>> fetchPromo() async {
    // return Future.delayed(const Duration(seconds: 2), () async {
    final List<Map<String, dynamic>> listPromo = [];
    print("Jalan");
    print(Config.baseUrlApi +
        'app-api/depan/promo/?key=0cc7da679bea04fea453c8062e06514d');

    final responsePromo = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/depan/promo/?key=0cc7da679bea04fea453c8062e06514d'));

    if (responsePromo.statusCode == 200) {
      final Map promo = jsonDecode(responsePromo.body);
      if (promo['data'].isNotEmpty) {
        for (var infoItem in promo['data']) {
          listPromo.add(infoItem);
        }
      }
    } else {
      print('Failed to load Promo');
      return [];
    }
    return listPromo;
    // });
  }

  Future<List<Map<String, dynamic>>> fetchPromoKhusus({int delay = 0}) async {
    return Future.delayed(Duration(seconds: delay), () async {
      final List<Map<String, dynamic>> listPromoKhusus = [];

      final responsePromoKhusus = await http.get(Uri.parse(Config.baseUrlApi +
          'app-api/depan/promohargakhusus/?key=0cc7da679bea04fea453c8062e06514d'));
      print("rauf promokhusus");
      print(Config.baseUrlApi +
          'app-api/depan/promohargakhusus/?key=0cc7da679bea04fea453c8062e06514d');
      if (responsePromoKhusus.statusCode == 200) {
        final Map promoKhusus = jsonDecode(responsePromoKhusus.body);
        if (promoKhusus['data'].isNotEmpty) {
          for (var infoItem in promoKhusus['data']) {
            listPromoKhusus.add(infoItem);
          }
        }
      } else {
        print('Failed to load Promo Khusus');
        return [];
      }
      return listPromoKhusus;
    });
  }

  Future<List<Map<String, dynamic>>> fetchProdukBaru({int delay = 0}) async {
    return Future.delayed(Duration(seconds: delay), () async {
      final List<Map<String, dynamic>> listProdukBaru = [];

      final responseProdukBaru = await http.get(Uri.parse(Config.baseUrlApi +
          'app-api/depan/produkbaru/?key=0cc7da679bea04fea453c8062e06514d'));
      if (responseProdukBaru.statusCode == 200) {
        final Map produkBaru = jsonDecode(responseProdukBaru.body);
        if (produkBaru['data'].isNotEmpty) {
          for (var infoItem in produkBaru['data']) {
            listProdukBaru.add(infoItem);
          }
        }
      } else {
        print('Failed to load Produk Baru');
        return [];
      }
      return listProdukBaru;
    });
  }

  Future<List<Map<String, dynamic>>> fetchProdukUnggulan(
      {int delay = 0}) async {
    return Future.delayed(Duration(seconds: delay), () async {
      final List<Map<String, dynamic>> listProdukUnggulan = [];

      final responseProdukUnggulan = await http.get(Uri.parse(Config
              .baseUrlApi +
          'app-api/depan/produkunggulan/?key=0cc7da679bea04fea453c8062e06514d'));
      if (responseProdukUnggulan.statusCode == 200) {
        final Map produkUnggulan = jsonDecode(responseProdukUnggulan.body);
        if (produkUnggulan['data'].isNotEmpty) {
          for (var infoItem in produkUnggulan['data']) {
            listProdukUnggulan.add(infoItem);
          }
        }
      } else {
        print('Failed to load Produk Unggulan');
        return [];
      }
      return listProdukUnggulan;
    });
  }

  // int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    futureBanner = fetchBanner();
    futureInfo = fetchInfo();
    futurePromo = fetchPromo();
    futurePromoKhusus = fetchPromoKhusus(delay: 3);
    futureProdukBaru = fetchProdukBaru(delay: 4);
    futureProdukUnggulan = fetchProdukUnggulan(delay: 5);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build beranda');
    return RefreshIndicator(
      displacement: 100,
      onRefresh: _refresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            HomeSilder(
              futureBanner: futureBanner,
              controller: _controller,
              indikator: true,
            ),
            HomeCategroy(),
            futureInfo != null || futureInfo != []
                ? HomeInfo(futureInfo: futureInfo)
                : Container(),
            futurePromo != [] || futurePromo != null
                ? HomePromo(futurePromo: futurePromo, createRoute: _createRoute)
                : Container(),
            futurePromoKhusus != null || futurePromoKhusus != []
                ? HomePromoKhusus(
                    futurePromoKhusus: futurePromoKhusus,
                    createRoute: _createRoute)
                : Container(),
            futureProdukBaru != null || futureProdukBaru != []
                ? HomeProdukBaru(
                    futureProdukBaru: futureProdukBaru,
                    createRoute: _createRoute)
                : Container(),
            futureProdukUnggulan != null || futureProdukUnggulan != []
                ? HomeProdukUnggulan(
                    futureProdukUnggulan: futureProdukUnggulan,
                    createRoute: _createRoute)
                : Container(),
            HomeCustomCategory(createRoute: _createRoute)
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _refresh() async {
    setState(() {
      futureBanner = fetchBanner();
      futureInfo = fetchInfo();
      futurePromo = fetchPromo();
      futurePromoKhusus = fetchPromoKhusus();
      futureProdukBaru = fetchProdukBaru();
      futureProdukUnggulan = fetchProdukUnggulan();
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
}
