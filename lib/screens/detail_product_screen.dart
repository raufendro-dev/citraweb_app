// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom; // that is
import 'package:mikrotik/providers/cart_provider.dart';
import 'package:mikrotik/screens/home_page_screen.dart';
import 'package:mikrotik/screens/product_by_category_screen.dart';
import 'package:mikrotik/screens/shoping_cart_screen.dart';
import 'package:mikrotik/widgets/app_bar_home.dart';
import 'package:mikrotik/widgets/end_drawer_home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import '../constant/config.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
// import '../widgets/enter_exit_route.dart';

class DetailProductScreen extends StatefulWidget {
  static const routeName = 'DetailProductScreen';
  final int productId;
  const DetailProductScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen>
    with AutomaticKeepAliveClientMixin<DetailProductScreen> {
  final _config = Config();

  late final Future<List<Map<String, dynamic>>> futureProdukDetail;

  late final Future<List<Map<String, dynamic>>> futureProdukLainnya;

  final authService = AuthService();

  Future<bool> addToCart() async {
    var res = await http.post(Uri.parse(Config.baseUrlApi +
        'app-api/keranjang/tambah/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        jsonDecode((await authService.strDataLogin).toString())['MKid'] +
        '&sess_id=' +
        jsonDecode((await authService.strDataLogin).toString())['sess_id'] +
        '&idbarang=' +
        (await futureProdukDetail.then((value) => value.first['id'])) +
        '&varian=$pilihVarian'));
    print(res.body);
    if (res.statusCode == 200 &&
        jsonDecode(res.body)['data'].first['status_add']) {
      return true;
    }
    if (res.statusCode == 200 &&
        !jsonDecode(res.body)['data'].first['status_add']) {
      Fluttertoast.showToast(
        msg: jsonDecode(res.body)['data'].first['status_msg'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
      );
      return false;
    }
    return false;
  }

  var namabuatwa = "";
  var adavariant = false;
  List<String> variantNames = [];
  String pilihVarian = "";
  Future<List<Map<String, dynamic>>> fetchProdukDetail() async {
    return Future.delayed(const Duration(milliseconds: 250), () async {
      final List<Map<String, dynamic>> listProdukDetail = [];

      final responseProdukDetail = await http.get(Uri.parse(Config.baseUrlApi +
          'app-api/produk/detail/?id=${widget.productId}&key=0cc7da679bea04fea453c8062e06514d'));
      print(Config.baseUrlApi +
          'app-api/produk/detail/?id=${widget.productId}&key=0cc7da679bea04fea453c8062e06514d');
      if (responseProdukDetail.statusCode == 200) {
        final Map produkDetail = jsonDecode(responseProdukDetail.body);
        if (produkDetail['data'].isNotEmpty) {
          for (var detail in produkDetail['data']) {
            listProdukDetail.add(detail);
          }
          setState(() {
            namabuatwa = produkDetail['data'][0]['nama'].toString();
            if (produkDetail['data'][0]['varian'] != "0") {
              print("tes");
              adavariant = true;
              for (var i = 0;
                  i < produkDetail['data'][0]['varian_array'].length;
                  i++) {
                if (i == 0) {
                  setState(() {
                    pilihVarian = produkDetail['data'][0]['varian_array'][i]
                        ['varian_nama'];
                  });
                }
                variantNames.add(
                    produkDetail['data'][0]['varian_array'][i]['varian_nama']);
              }
              print(variantNames);
            }
          });
        }
      } else {
        print('Failed to load Detail Produk');
      }
      return listProdukDetail;
    });
  }

  Future<List<Map<String, dynamic>>> fetchProdukLainnya(int id) async {
    final List<Map<String, dynamic>> listProdukLain = [];

    final responseProdukLain = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/produk/wherekategori/?id=$id&key=0cc7da679bea04fea453c8062e06514d'));
    if (responseProdukLain.statusCode == 200) {
      final Map produkLain = jsonDecode(responseProdukLain.body);
      if (produkLain['data'].isNotEmpty) {
        for (var infoItem in produkLain['data']) {
          listProdukLain.add(infoItem);
        }
      }
    } else {
      print('Failed to load Produk Lainnya');
      print(
          'app-api/produk/wherekategori/?id=$id&key=0cc7da679bea04fea453c8062e06514d');
    }
    return listProdukLain;
  }

  @override
  void initState() {
    super.initState();
    futureProdukDetail = fetchProdukDetail();

    futureProdukLainnya = futureProdukDetail.then((value) {
      return fetchProdukLainnya(int.parse(value.first['kategori']))
          .then((value) => value);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build detail page');
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: FaIcon(FontAwesomeIcons.whatsapp),
        label: Text("Tanya Kami"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          print(namabuatwa);
          String url =
              "https://wa.me/+628112039555/?text=Halo, Saya mau menanyakan tentang produk " +
                  namabuatwa;
          launch(url);
        },
      ),
      appBar: const AppBarHome(
        leading: Leading.back,
      ),
      endDrawer: const EndDrawerHome(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureProdukDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var detail = snapshot.data!.first;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(children: [
                        Center(
                          child: CachedNetworkImage(
                            // fit: BoxFit.cover,
                            imageUrl: _config.mktToCst(detail['gambar_besar']),
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                            )),
                            errorWidget: (context, url, error) => const Align(
                                alignment: Alignment.center,
                                child: Icon(Icons.error)),
                          ),
                        ),
                        if (detail['status_barang'] == 'HABIS')
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withOpacity(0.7),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                child: Text(
                                  detail['status_barang'],
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onError),
                                ),
                              ),
                            ),
                          )
                      ]),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              _createRoute(
                                ProductByCategoryScreen(
                                  idKategori: int.parse(detail['kategori']),
                                  namaKategori: detail['nama_kategori'],
                                ),
                                slideDirection.toLeft,
                              ),
                            );
                          },
                          child: Text(
                            detail['nama_kategori'],
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detail['nama'],
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Kode : ${detail['kode']}",
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        detail['harga_rp'] != "0"
                            ? Text(
                                detail['harga_rp'].replaceAll(',00', ''),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        color: Theme.of(context).primaryColor),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )
                            : Container(),
                        const SizedBox(
                          height: 6,
                        ),
                        if (detail['status_barang'] != 'HABIS')
                          Container(
                            color: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              detail['status_barang'],
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    // margin: const EdgeInsets.only(top: 18),
                    padding: const EdgeInsets.all(14),
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INFORMASI BARANG',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                'Stock',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const Text(':'),
                            Expanded(
                                child: Text(
                              detail['status_barang'],
                              textAlign: TextAlign.end,
                            ))
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                'Kode',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const Text(':'),
                            Expanded(
                              child: Text(
                                detail['kode'],
                                textAlign: TextAlign.end,
                              ),
                            )
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              onPressed: () async {
                                if (await canLaunch(detail['brosur'])) {
                                  await launch(
                                    detail['brosur'],
                                  );
                                } else {
                                  throw 'Could not launch ${detail['brosur']}';
                                }
                              },
                              label: const Text('Download Brosur'),
                              icon: const Icon(Icons.download),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 18),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Text(
                            'DESKRIPSI',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (rectangle) {
                              return const LinearGradient(
                                colors: [Colors.white, Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(rectangle);
                            },
                            child: Container(
                              height: 150, //height of TabBarView
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                              ),
                              child: Html(
                                data: detail['ket_pendek']
                                    .toString()
                                    .replaceAll("Â", ""),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.background,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 0),
                            alignment: Alignment.center,
                            child: TextButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context)
                                          .colorScheme
                                          .background)),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Selengkapnya(
                                              deskripsi: detail['ket_pendek'],
                                              spesifikasi: detail[
                                                      'ket_panjang'] +
                                                  detail['video_array_iframe'],
                                            )));
                              },
                              child: const Text('Selengkapnya'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 18),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Text(
                            'SPESIFIKASI',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (rectangle) {
                              return const LinearGradient(
                                colors: [Colors.white, Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(rectangle);
                            },
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              height: 150, //height of TabBarView
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                              ),
                              child: Html(
                                  data: detail['ket_panjang']
                                      .toString()
                                      .replaceAll("Â", ""),
                                  customRender: {
                                    "table": (context, child) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child:
                                            (context.tree as TableLayoutElement)
                                                .toWidget(context),
                                      );
                                    }
                                  }),
                            ),
                          ),
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.background,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 0),
                            alignment: Alignment.center,
                            child: TextButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context)
                                          .colorScheme
                                          .background)),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Selengkapnya(
                                              deskripsi: detail['ket_pendek'],
                                              spesifikasi: detail[
                                                      'ket_panjang'] +
                                                  detail['video_array_iframe'],
                                            )));
                              },
                              child: const Text('Selengkapnya'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                      future: futureProdukLainnya,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(14, 2, 6, 2),
                                color: const Color(0xFF505BA8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('PRODUK LAINNYA',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .background)),
                                    SizedBox(
                                      height: 40,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              primary: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              alignment: Alignment.center),
                                          label: const Text(
                                            'Selengkapnya',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal),
                                          ),
                                          icon: Container(
                                              padding: EdgeInsets.zero,
                                              width: 14,
                                              child: const Icon(
                                                  Icons.keyboard_arrow_right)),
                                          onPressed: () async {
                                            Navigator.of(context).push(
                                              _createRoute(
                                                ProductByCategoryScreen(
                                                  idKategori: int.parse(
                                                      (await futureProdukDetail)
                                                          .first['kategori']),
                                                  namaKategori:
                                                      (await futureProdukDetail)
                                                              .first[
                                                          'nama_kategori'],
                                                ),
                                                slideDirection.toLeft,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
                                    snapshot.data!.length > 6
                                        ? 6
                                        : snapshot.data!.length,
                                    (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(_createRoute(
                                                  DetailProductScreen(
                                                    productId: int.parse(
                                                        snapshot.data![index]
                                                            ['id']),
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
                                                      imageUrl: _config
                                                          .mktToCst(snapshot
                                                                  .data![index]
                                                              ['gambar_kecil']),
                                                      placeholder: (context,
                                                              url) =>
                                                          const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      )),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
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
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 2),
                                                      child: Text(
                                                        snapshot.data![index]
                                                            ['status_barang'],
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
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
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 2),
                                                      child: Text(
                                                        snapshot.data![index]
                                                            ['status_barang'],
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onError),
                                                      ),
                                                    ),
                                                  ),
                                                if (snapshot.data![index]
                                                        ['status_barang'] ==
                                                    'CALL TO BUY')
                                                  Positioned(
                                                    top: 2,
                                                    right: 1,
                                                    child: Container(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 2),
                                                      child: Text(
                                                        snapshot.data![index]
                                                            ['status_barang'],
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onError),
                                                      ),
                                                    ),
                                                  )
                                              ]),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Text(
                                                      snapshot.data![index]
                                                          ['nama_kategori'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    Text(
                                                      snapshot.data![index]
                                                          ['nama'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    snapshot.data![index]
                                                                ['harga_rp'] !=
                                                            "0"
                                                        ? Text(
                                                            snapshot
                                                                .data![index]
                                                                    ['harga_rp']
                                                                .replaceAll(
                                                                    ',00', ''),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText2!
                                                                .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .error),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                      }),
                ],
              ),
            );
          }

          // By default, show a loading spinner.
          return const Center(
              child: CircularProgressIndicator(
            strokeWidth: 2,
          ));
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            color: Theme.of(context).colorScheme.background,
            child: FutureBuilder<List<Map<String, dynamic>>>(
                future: futureProdukDetail,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var cartProvider =
                        Provider.of<CartProvider>(context, listen: true);
                    return Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 50,
                          height: double.infinity,
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                              ),
                              onPressed: snapshot
                                          .data!.first['status_barang'] ==
                                      'HABIS'
                                  ? null
                                  : snapshot.data!.first['status_barang'] ==
                                          'CALL TO BUY'
                                      ? null
                                      : () async {
                                          print(await authService.strDataLogin);
                                          if (await authService
                                              .cekLogin(context)) {
                                            print('addtocart');
                                            // addtocart
                                            if (await addToCart()) {
                                              cartProvider.plushItem();
                                              authService.fetchCart(context);
                                              print(cartProvider.jumlahItem);
                                            }
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                  builder:
                                                      (BuildContext context) =>
                                                          LoginScreen(),
                                                )).then((value) async {
                                              if ((await authService
                                                      .strDataLogin)
                                                  .toString()
                                                  .isNotEmpty) {
                                                addToCart();
                                                cartProvider.plushItem();
                                                Navigator.of(context)
                                                    .pushNamedAndRemoveUntil(
                                                        HomePageScreen
                                                            .routeName,
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);

                                                Navigator.pushNamed(
                                                    context,
                                                    ShopingCartScreen
                                                        .routeName);
                                              }
                                            });
                                          }
                                        },
                              child: const Icon(Icons.add_shopping_cart)),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                              ),
                              onPressed: snapshot
                                          .data!.first['status_barang'] ==
                                      'HABIS'
                                  ? null
                                  : snapshot.data!.first['status_barang'] ==
                                          'CALL TO BUY'
                                      ? null
                                      : () async {
                                          if (adavariant == false) {
                                            print('belisekarang');
                                            print(
                                                await authService.strDataLogin);
                                            if (await authService
                                                .cekLogin(context)) {
                                              // addtocart
                                              // addToCart();
                                              if (await addToCart()) {
                                                // authService.fetchCart(context).then(
                                                //   (value) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute<void>(
                                                      builder: (BuildContext
                                                              context) =>
                                                          const ShopingCartScreen(),
                                                    ));
                                                //   return value;
                                                // },
                                                // );
                                                cartProvider.plushItem();
                                                // print(cartProvider.jumlahItem);
                                              }
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute<void>(
                                                    builder: (BuildContext
                                                            context) =>
                                                        LoginScreen(),
                                                  )).then((value) async {
                                                if ((await authService
                                                        .strDataLogin)
                                                    .toString()
                                                    .isNotEmpty) {
                                                  addToCart();
                                                  cartProvider.plushItem();
                                                  Navigator.of(context)
                                                      .pushNamedAndRemoveUntil(
                                                          HomePageScreen
                                                              .routeName,
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false);

                                                  Navigator.pushNamed(
                                                      context,
                                                      ShopingCartScreen
                                                          .routeName);
                                                }
                                              });
                                            }
                                          } else {
                                            if (await authService
                                                .cekLogin(context)) {
                                              // addtocart
                                              // addToCart();\
                                              showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return Container(
                                                        height: 200,
                                                        child: Column(
                                                          // mainAxisAlignment:
                                                          //     MainAxisAlignment
                                                          //         .center,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10),
                                                              child: Center(
                                                                child: Text(
                                                                  "Pilih Varian",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Center(
                                                              child:
                                                                  DropdownButton<
                                                                      String>(
                                                                value:
                                                                    pilihVarian, // Set initial value
                                                                items: variantNames.map<
                                                                    DropdownMenuItem<
                                                                        String>>((String
                                                                    value) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value),
                                                                  );
                                                                }).toList(),
                                                                onChanged: (String?
                                                                    newValue) {
                                                                  // Handle dropdown selection change
                                                                  setState(() {
                                                                    print(
                                                                        newValue);
                                                                    pilihVarian =
                                                                        newValue
                                                                            .toString();
                                                                    // Update selected value (if using a stateful widget)
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 23,
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  'Lanjutkan'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                              //=======================
                                              // if (await addToCart()) {
                                              //   // authService.fetchCart(context).then(
                                              //   //   (value) {
                                              //   Navigator.push(
                                              //       context,
                                              //       MaterialPageRoute<void>(
                                              //         builder: (BuildContext
                                              //                 context) =>
                                              //             const ShopingCartScreen(),
                                              //       ));
                                              //   //   return value;
                                              //   // },
                                              //   // );
                                              //   cartProvider.plushItem();

                                              //   // print(cartProvider.jumlahItem);
                                              // }
                                              //========================
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute<void>(
                                                    builder: (BuildContext
                                                            context) =>
                                                        LoginScreen(),
                                                  )).then((value) async {
                                                if ((await authService
                                                        .strDataLogin)
                                                    .toString()
                                                    .isNotEmpty) {
                                                  addToCart();
                                                  cartProvider.plushItem();
                                                  Navigator.of(context)
                                                      .pushNamedAndRemoveUntil(
                                                          HomePageScreen
                                                              .routeName,
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false);

                                                  Navigator.pushNamed(
                                                      context,
                                                      ShopingCartScreen
                                                          .routeName);
                                                }
                                              });
                                            }
                                          }
                                        },
                              child: Text(
                                snapshot.data!.first['status_barang'] == 'HABIS'
                                    ? 'Stok Habis'
                                    : snapshot.data!.first['status_barang'] ==
                                            'CALL TO BUY'
                                        ? "Call to buy"
                                        : 'Beli Sekarang',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        color: snapshot.data!
                                                    .first['status_barang'] ==
                                                'HABIS'
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .background),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 50,
                        height: double.infinity,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                            ),
                            onPressed: () {},
                            child: const Icon(Icons.add_shopping_cart)),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              'Beli Sekarang',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                })),
      ),
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

  @override
  bool get wantKeepAlive => true;
}

class Selengkapnya extends StatelessWidget {
  final String deskripsi;
  final String spesifikasi;
  const Selengkapnya(
      {Key? key, required this.deskripsi, required this.spesifikasi})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Detail Produk',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const Text(
                'Deskripsi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Html(
              data: deskripsi.toString().replaceAll("Â", ""),
            ),
            Container(
              color: Colors.black12,
              height: 14,
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const Text(
                'Spesifikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Html(
              data: spesifikasi.toString().replaceAll("Â", ""),
              customRender: {
                "table": (context, child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child:
                        (context.tree as TableLayoutElement).toWidget(context),
                  );
                }
              },
              style: {
                "td": Style(
                  border: Border.all(color: Colors.grey),
                ),
              },
              onLinkTap: (String? url, RenderContext context,
                  Map<String, String> attributes, dom.Element? element) async {
                //open URL in webview, or launch URL in browser, or any other logic here
                if (await canLaunch(url!)) {
                  await launch(
                    url,
                  );
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
