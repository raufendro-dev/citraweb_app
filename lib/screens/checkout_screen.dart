// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:mikrotik/screens/home_page_screen.dart';
import 'package:mikrotik/screens/order_sukses_screen.dart';
import 'package:mikrotik/screens/pilih_alamat_screen.dart';
import '../constant/config.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String totalHargaBarang = '0';
  String ppn = '0';
  String ongkir = '0';
  String totalYangHarusDibayar = '0';
  String totalQtyBarang = '0';
  int isDiambil = 0;
  int _mkIdTujuan = 0;

  late Future<List<Map<String, dynamic>>> futureCheckout;

  Future<List<Map<String, dynamic>>> fetchCheckout() async {
    String id = await AuthService().idUser;
    String sessionI = await AuthService().sessId;

    final List<Map<String, dynamic>> listCheckout = [];
    final responseCheckout = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/keranjang/verifikasi/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionI&isDiambil=$isDiambil&MKid_tujuan=$_mkIdTujuan'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/keranjang/verifikasi/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionI&isDiambil=$isDiambil&MKid_tujuan=$_mkIdTujuan'));

    print(responseCheckout.body);
    if (responseCheckout.statusCode == 200) {
      final Map checkout = jsonDecode(responseCheckout.body);
      if (checkout['data'].isNotEmpty) {
        for (var detail in checkout['data']) {
          listCheckout.add(detail);
        }
      }
    } else {
      print('Failed to load Detail Checkout');
    }
    print(listCheckout);
    setState(() {
      totalHargaBarang = listCheckout.first['total_harga_barang'];
      ppn = listCheckout.first['ppn_rp'];
      ongkir = listCheckout.first['ada_biaya_ongkir']
          ? listCheckout.first['data_ongkir'].first['ongkos_kirim']
          : '0';
      totalYangHarusDibayar = listCheckout.first['total_yang_harus_dibayar'];

      int qtyBarang = 0;
      print(listCheckout.first['data_barang']);
      for (var item in listCheckout.first['data_barang']) {
        qtyBarang += int.parse(item['jum_barang']);
      }
      totalQtyBarang = qtyBarang.toString();
    });
    return listCheckout;
  }

  Future<bool> pesan() async {
    String id = await AuthService().idUser;
    String sessionI = await AuthService().sessId;
    final responsePesan = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/keranjang/selesai/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionI&isDiambil=$isDiambil&MKid_tujuan=$_mkIdTujuan'));
    if (responsePesan.statusCode == 200) {
      final Map pesanObj = jsonDecode(responsePesan.body);
      if (pesanObj['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } else {
      print('Failed to process order');
      return false;
    }
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
    futureCheckout = fetchCheckout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureCheckout,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final checkout = snapshot.data!.first;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alamat Pengiriman :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            checkout['ada_alamat_pengiriman']
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (checkout['data_alamat_pengiriman']
                                          .first['nama']
                                          .isNotEmpty)
                                        Text(checkout['data_alamat_pengiriman']
                                                .first['nama'] +
                                            ' | ' +
                                            checkout['data_alamat_pengiriman']
                                                .first['telp']),
                                      if (checkout['data_alamat_pengiriman']
                                          .first['perusahaan']
                                          .isNotEmpty)
                                        Text(checkout['data_alamat_pengiriman']
                                            .first['perusahaan']),
                                      if (checkout['data_alamat_pengiriman']
                                          .first['nama_kota']
                                          .isNotEmpty)
                                        Text(checkout['data_alamat_pengiriman']
                                            .first['nama_kota']),
                                      if (checkout['data_alamat_pengiriman']
                                          .first['alamat']
                                          .isNotEmpty)
                                        Text(checkout['data_alamat_pengiriman']
                                            .first['alamat']),
                                      if (checkout['data_alamat_pengiriman']
                                          .first['kodepos']
                                          .isNotEmpty)
                                        Text(checkout['data_alamat_pengiriman']
                                            .first['kodepos']),
                                    ],
                                  )
                                : Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0),
                                      child: Text(checkout['data_ongkir']
                                          .first['kota_tujuan']),
                                    ),
                                  ),
                            SizedBox(
                              width: 36,
                              child: IconButton(
                                onPressed: () {
                                  print('pilih alamat');
                                  Navigator.of(context)
                                      .push(
                                    _createRoute(
                                        PilihAlamatScreen(
                                          isDiambil: isDiambil,
                                          mkIdTujuan: _mkIdTujuan,
                                        ),
                                        slideDirection.toLeft),
                                  )
                                      .then((value) {
                                    if (value.toString() != 'null') {
                                      var alamatPilihan = jsonDecode(value);
                                      print(alamatPilihan);
                                      setState(() {
                                        isDiambil = alamatPilihan['isDiambil'];
                                        _mkIdTujuan =
                                            alamatPilihan['MKid_tujuan'];
                                      });
                                      futureCheckout = fetchCheckout();
                                    }
                                  });
                                },
                                icon: const Icon(Icons.chevron_right),
                                // splashColor: Colors.red,
                                // splashRadius: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Html(
                              data: '</small>' +
                                  checkout['msg_berat'] +
                                  '</small>'),
                        ),
                        const Divider(height: 0),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(checkout['data_ganti_ongkir']
                                    .firstWhere((item) =>
                                        item['isSelect'] ==
                                        true)['isDiambil_txt']),
                              ),
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12)),
                                      ),
                                      backgroundColor: Colors.grey[200],
                                      builder: (BuildContext context) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                              // color: Colors.grey,
                                              child: Text(
                                                'Metode Pengiriman',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6!
                                                    .copyWith(
                                                        color: Colors.black54),
                                              ),
                                            ),
                                            ...checkout['data_ganti_ongkir']
                                                .map((jenisPengiriman) {
                                              return Column(children: [
                                                const Divider(height: 0),
                                                ListTile(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 12,
                                                    vertical: 0,
                                                  ),
                                                  tileColor: Theme.of(context)
                                                      .colorScheme
                                                      .background,
                                                  onTap: () {
                                                    setState(() {
                                                      isDiambil =
                                                          jenisPengiriman[
                                                              'isDiambil'];
                                                      _mkIdTujuan = 0;
                                                      futureCheckout =
                                                          fetchCheckout();
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  title: Text(jenisPengiriman[
                                                      'isDiambil_txt']),
                                                  trailing: jenisPengiriman[
                                                          'isSelect']
                                                      ? Icon(
                                                          Icons.check,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        )
                                                      : const Text(''),
                                                ),
                                              ]);
                                            }),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  // splashColor: Colors.red,
                                  // splashRadius: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 0,
                    ),
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      children: [
                        ...checkout['data_barang'].map((elem) {
                          return Column(
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      margin: const EdgeInsets.all(8),
                                      // color: Colors.grey,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: Config()
                                            .mktToCst(elem['gambar_kecil']),
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator(
                                          strokeWidth: 2,
                                        )),
                                        errorWidget: (context, url, error) =>
                                            const Align(
                                                alignment: Alignment.center,
                                                child: Icon(Icons.error)),
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              elem['nama_barang'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              elem['kode_barang'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            ),
                                            const SizedBox(height: 6),
                                            Text('Rp ' + elem['harga_barang']),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      alignment: Alignment.centerRight,
                                      width: 40,
                                      // height: double.infinity,
                                      // color: Colors.red,
                                      child: Text('x' + elem['jum_barang']),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Pesanan ($totalQtyBarang Produk)'),
                              Text(totalHargaBarang),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal Produk'),
                                  Text(totalHargaBarang),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [const Text('PPN 10%'), Text(ppn)],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Biaya Pengiriman'),
                                  Text(ongkir),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Pembayaran'),
                              Text(
                                totalYangHarusDibayar,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (checkout['msg_biaya_ongkir'] != '')
                          const Divider(height: 12),
                        if (checkout['msg_biaya_ongkir'] != '')
                          Container(
                            color: Theme.of(context).colorScheme.background,
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
                            child: Text(
                              checkout['msg_biaya_ongkir'],
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // if (checkout['msg_biaya_ongkir'] != '')
                  //   Container(
                  //     color: Theme.of(context).colorScheme.background,
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 8,
                  //     ),
                  //     child: Text(
                  //       checkout['msg_biaya_ongkir'],
                  //       style: Theme.of(context).textTheme.caption,
                  //     ),
                  //   ),
                ],
              ),
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
                        Text(
                          'Rp ' + totalYangHarusDibayar,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
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
                      onPressed: () async {
                        if (await pesan()) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            HomePageScreen.routeName,
                            (Route<dynamic> route) => false,
                            arguments: 4,
                          );
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const OrderSuksesScreen()));
                        } else {}
                      },
                      child: Text(
                        'Pesan',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
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
    );
  }
}
