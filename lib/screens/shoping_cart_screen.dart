// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../constant/config.dart';
import '../providers/cart_provider.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../screens/detail_product_screen.dart';
import '../screens/checkout_screen.dart';

class ShopingCartScreen extends StatefulWidget {
  const ShopingCartScreen({Key? key}) : super(key: key);
  static const routeName = 'ShopingCartScreen';

  @override
  _ShopingCartScreenState createState() => _ShopingCartScreenState();
}

class _ShopingCartScreenState extends State<ShopingCartScreen> {
  final auth = AuthService();
  late Future<List<Map<String, dynamic>>>? futureListProduk =
      fetchShopingCart();

  Future<List<Map<String, dynamic>>> fetchShopingCart() async {
    final List<Map<String, dynamic>> listProduk = [];
    final responseShopingCart = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/keranjang/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        (await auth.idUser) +
        '&sess_id=' +
        (await auth.sessId)));
    if (responseShopingCart.statusCode == 200) {
      final Map produk = jsonDecode(responseShopingCart.body);
      if (produk['data'].isNotEmpty) {
        for (var detail in produk['data']) {
          listProduk.add(detail);
        }
      }
    } else {
      print('Failed to load Detail Produk');
    }
    // print(listProduk);
    return listProduk;
  }

  Future<bool> changeQty({
    required String idCart,
    required String idBarang,
    required String varian,
    required int qty,
  }) async {
    print(jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "iduser": await auth.idUser,
      "sess_id": await auth.sessId,
      "data_barang": [
        {
          "id": idCart,
          "idbarang": idBarang,
          "jum_barang": qty,
          "varian": varian
        }
      ]
    }));
    if (qty > 20) {
      return false;
    }
    final responseShopingCart = await http.post(
        Uri.parse(Config.baseUrlApi + 'app-api/keranjang/ubah/'),
        body: jsonEncode({
          "key": "0cc7da679bea04fea453c8062e06514d",
          "iduser": await auth.idUser,
          "sess_id": await auth.sessId,
          "data_barang": [
            {
              "id": idCart,
              "idbarang": idBarang,
              "jum_barang": qty,
              "varian": varian
            }
          ]
        }));
    if (responseShopingCart.statusCode == 200) {
      print(responseShopingCart.body);
      return true;
    } else {
      print('Failed to load Detail Produk');
    }
    return false;
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
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      auth.fetchCart(context).then((value) {
        setState(() {});
        return value;
      });
    });

    // futureListProduk = fetchShopingCart();
  }

  @override
  Widget build(BuildContext context) {
    print('build shoping cart');
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            color: Theme.of(context).colorScheme.background,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Keranjang Saya'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureListProduk,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!.first;
              if (data['ada_kerangjang']) {
                // List<TextEditingController> qtyControllers = [];

                return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                          height: 0,
                          color: Colors.grey[200],
                          indent: 12,
                          endIndent: 12,
                          thickness: 1,
                        ),
                    scrollDirection: Axis.vertical,
                    itemCount: data['data_barang'].length,
                    itemBuilder: (BuildContext context, int index) {
                      TextEditingController qtyController =
                          TextEditingController(
                        text:
                            data['data_barang'][index]['jum_barang'].toString(),
                      );
                      // FocusNode _focus = FocusNode();

                      // _focus.addListener(() async {
                      //   debugPrint("Focus: ${_focus.hasFocus.toString()}");
                      //   if (!_focus.hasFocus) {
                      //     if (qtyController.text.isEmpty ||
                      //         qtyController.text == '0') {
                      //       qtyController.text = '1';
                      //     }
                      //     var qty = int.parse(qtyController.text);
                      //     if (qty > 20) {
                      //       qtyController.text = '20';
                      //       qtyController.selection =
                      //           TextSelection.fromPosition(TextPosition(
                      //               offset: qtyController.text.length));
                      //       qty = 20;
                      //     }
                      //     print('change typing');
                      //     bool isChanged = await changeQty(
                      //       idCart: data['data_barang'][index]['id'],
                      //       idBarang: data['data_barang'][index]['idbarang'],
                      //       qty: qty,
                      //     );
                      //     if (isChanged) {
                      //       print('changed');
                      //       auth.fetchCart(context);
                      //       // var fetchJumlahCart = await auth.fetchCart(context);
                      //       // cartProvider
                      //       //     .setJumlahItem(fetchJumlahCart['jumlahItem']);
                      //       // cartProvider
                      //       //     .setTotalHarga(fetchJumlahCart['totalHarga']);

                      //       // futureListProduk!.then((value) {
                      //       setState(() {
                      //         futureListProduk = fetchShopingCart();
                      //       });
                      //       // return value;
                      //       // });
                      //     } else {
                      //       qtyController.text =
                      //           data['data_barang'][index]['jum_barang'];
                      //     }
                      //   }
                      // });
                      return Container(
                        color: Theme.of(context).colorScheme.background,
                        padding: const EdgeInsets.all(12),
                        // margin: const EdgeInsets.only(bottom: 12),
                        width: double.infinity,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(_createRoute(
                                      DetailProductScreen(
                                        productId: int.parse(data['data_barang']
                                            [index]['idbarang']),
                                      ),
                                      slideDirection.toLeft));
                                },
                                child: Container(
                                  height: 100,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  width: 100,
                                  child: CachedNetworkImage(
                                    // fit: BoxFit.cover,
                                    imageUrl: Config().mktToCst(
                                        data['data_barang'][index]
                                            ['gambar_besar']),
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    )),
                                    errorWidget: (context, url, error) =>
                                        const Align(
                                            alignment: Alignment.center,
                                            child: Icon(Icons.error)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(_createRoute(
                                                  DetailProductScreen(
                                                    productId: int.parse(
                                                        data['data_barang']
                                                                [index]
                                                            ['idbarang']),
                                                  ),
                                                  slideDirection.toLeft));
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['data_barang'][index]
                                                  ['nama_barang'],
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            data['data_barang'][index]
                                                        ['varian'] !=
                                                    ""
                                                ? Column(
                                                    children: [
                                                      Text(
                                                        'Varian ' +
                                                            data['data_barang']
                                                                    [index]
                                                                ['varian'],
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary),
                                                      ),
                                                      const SizedBox(
                                                        height: 6,
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                            Text(
                                              'Rp ' +
                                                  data['data_barang'][index]
                                                      ['harga_barang'],
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.zero,
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 0,
                                                        color: Colors.grey)),
                                                child: IconButton(
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () async {
                                                      var qty = int.parse(
                                                              qtyController
                                                                  .text) -
                                                          1;
                                                      print('-');

                                                      if (qty <= 0) {
                                                        qty = 1;
                                                        qtyController.text =
                                                            qty.toString();
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                'Minimal qty per item 1',
                                                            toastLength: Toast
                                                                .LENGTH_LONG,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            backgroundColor:
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.7));
                                                      } else {
                                                        qtyController.text =
                                                            qty.toString();
                                                      }
                                                      changeQty(
                                                        idCart:
                                                            data['data_barang']
                                                                [index]['id'],
                                                        idBarang:
                                                            data['data_barang']
                                                                    [index]
                                                                ['idbarang'],
                                                        varian:
                                                            data['data_barang']
                                                                    [index]
                                                                ['varian'],
                                                        qty: qty,
                                                      ).then((value) {
                                                        if (value) {
                                                          // setState(() {
                                                          // cartProvider
                                                          //     .setJumlahItem(
                                                          //         qty);
                                                          auth.fetchCart(
                                                              context);
                                                          // futureListProduk =
                                                          //     fetchShopingCart();
                                                          // });
                                                        }
                                                      });
                                                      // bool isMined =
                                                      //     await changeQty(
                                                      //   idCart:
                                                      //       data['data_barang']
                                                      //           [index]['id'],
                                                      //   idBarang:
                                                      //       data['data_barang']
                                                      //               [index]
                                                      //           ['idbarang'],
                                                      //   qty: qty,
                                                      // );
                                                      // if (isMined) {
                                                      //   print('minus');
                                                      //   auth
                                                      //       .fetchCart(context)
                                                      //       .then(
                                                      //     (value) {
                                                      //       setState(
                                                      //         () {
                                                      //           // cartProvider
                                                      //           //     .minItem();
                                                      //           futureListProduk =
                                                      //               fetchShopingCart();
                                                      //         },
                                                      //       );
                                                      //       return value;
                                                      //     },
                                                      //   );
                                                      // }
                                                    },
                                                    icon: const Icon(
                                                        Icons.remove)),
                                              ),
                                              Container(
                                                width: 40,
                                                height: 28,
                                                decoration: const BoxDecoration(
                                                  border: Border.symmetric(
                                                    horizontal: BorderSide(
                                                      width: 0,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                child: Focus(
                                                  onFocusChange:
                                                      (hasFocus) async {
                                                    if (!hasFocus) {
                                                      if (qtyController
                                                              .text.isEmpty ||
                                                          qtyController.text ==
                                                              '0') {
                                                        qtyController.text =
                                                            '1';
                                                      }
                                                      var qty = int.parse(
                                                          qtyController.text);
                                                      if (qty > 20) {
                                                        qtyController.text =
                                                            '20';
                                                        qtyController
                                                                .selection =
                                                            TextSelection.fromPosition(
                                                                TextPosition(
                                                                    offset: qtyController
                                                                        .text
                                                                        .length));
                                                        qty = 20;
                                                      }
                                                      print('change typing');
                                                      changeQty(
                                                        idCart:
                                                            data['data_barang']
                                                                [index]['id'],
                                                        idBarang:
                                                            data['data_barang']
                                                                    [index]
                                                                ['idbarang'],
                                                        varian:
                                                            data['data_barang']
                                                                    [index]
                                                                ['varian'],
                                                        qty: qty,
                                                      ).then((value) {
                                                        if (value) {
                                                          auth.fetchCart(
                                                              context);
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: TextFormField(
                                                    // focusNode: _focus,
                                                    controller: qtyController,
                                                    textAlign: TextAlign.center,
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .center,
                                                    decoration:
                                                        const InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(4),
                                                      // isDense: true,
                                                      border:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    onChanged: (value) async {},
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.zero,
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 0,
                                                        color: Colors.grey)),
                                                child: IconButton(
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () async {
                                                      var qty = int.parse(
                                                              qtyController
                                                                  .text) +
                                                          1;
                                                      print('+');
                                                      if (qty > 100) {
                                                        qty = 100;
                                                        qtyController.text =
                                                            qty.toString();
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                'Maksimal qty per item 100',
                                                            toastLength: Toast
                                                                .LENGTH_LONG,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            backgroundColor:
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.7));
                                                      } else {
                                                        qtyController.text =
                                                            qty.toString();
                                                      }

                                                      changeQty(
                                                        idCart:
                                                            data['data_barang']
                                                                [index]['id'],
                                                        idBarang:
                                                            data['data_barang']
                                                                    [index]
                                                                ['idbarang'],
                                                        varian:
                                                            data['data_barang']
                                                                    [index]
                                                                ['idbarang'],
                                                        qty: qty,
                                                      ).then((value) {
                                                        if (value) {
                                                          // setState(() {
                                                          // cartProvider
                                                          //     .setJumlahItem(
                                                          //         qty);
                                                          auth.fetchCart(
                                                              context);
                                                          // futureListProduk =
                                                          //     fetchShopingCart();
                                                          // });
                                                        }
                                                      });
                                                      // bool isAdded =
                                                      //     await changeQty(
                                                      //   idCart: data[
                                                      //           'data_barang']
                                                      //       [index]['id'],
                                                      //   idBarang:
                                                      //       data['data_barang']
                                                      //               [
                                                      //               index]
                                                      //           [
                                                      //           'idbarang'],
                                                      //   qty: qty,
                                                      // );
                                                      // if (isAdded) {
                                                      //   setState(() {
                                                      //     print('added');
                                                      //     cartProvider
                                                      //         .plushItem();
                                                      //     futureListProduk =
                                                      //         fetchShopingCart()
                                                      //             .then(
                                                      //       (value) {
                                                      //         auth.fetchCart(
                                                      //             context);
                                                      //         return value;
                                                      //       },
                                                      //     );
                                                      //     print(
                                                      //         'rebuil yok');
                                                      //   });
                                                      // }
                                                    },
                                                    icon:
                                                        const Icon(Icons.add)),
                                              ),
                                            ],
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              // bool isDeleted = await changeQty(
                                              changeQty(
                                                idCart: data['data_barang']
                                                    [index]['id'],
                                                idBarang: data['data_barang']
                                                    [index]['idbarang'],
                                                varian: data['data_barang']
                                                    [index]['varian'],
                                                qty: 0,
                                              ).then((isDeleted) async {
                                                if (isDeleted) {
                                                  auth.fetchCart(context).then(
                                                    (value) {
                                                      setState(
                                                        () {
                                                          futureListProduk =
                                                              fetchShopingCart();
                                                        },
                                                      );
                                                      return value;
                                                    },
                                                  );
                                                  print('deleted');
                                                  print('rebuil yok');
                                                }
                                                return isDeleted;
                                              });
                                            },
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                      );
                    });
              }
              return const Center(
                child: Text('Keranjang Belanja Kosong'),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Harga Barang'),
                        Consumer<CartProvider>(builder: (context, cart, child) {
                          return Text(
                            'Rp ' + cart.totalHarga,
                            style: Theme.of(context).textTheme.bodyText2,
                          );
                        }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Diskon'),
                        Consumer<CartProvider>(builder: (context, cart, child) {
                          return Text(
                            'Rp ' + cart.diskon,
                            style: Theme.of(context).textTheme.bodyText2,
                          );
                        }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('PPN 11%'),
                        Consumer<CartProvider>(builder: (context, cart, child) {
                          return Text(
                            'Rp ' + cart.ppn,
                            style: Theme.of(context).textTheme.bodyText2,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 0,
                thickness: 0.5,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Theme.of(context).colorScheme.background,
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total',
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                          ),
                          Consumer<CartProvider>(
                              builder: (context, cart, child) {
                            return Text(
                              'Rp ' + cart.totalSebelumOngkir,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        onPressed: cartProvider.jumlahItem == 0
                            ? null
                            : () {
                                Navigator.of(context).push(_createRoute(
                                    const CheckoutScreen(),
                                    slideDirection.toLeft));
                              },
                        child: Text(
                          'Checkout',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.surface),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
