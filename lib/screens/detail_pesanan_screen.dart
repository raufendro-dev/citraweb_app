// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/main.dart';
import 'package:mikrotik/screens/log_status_order.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPesananScreen extends StatefulWidget {
  const DetailPesananScreen({Key? key, required this.noNota}) : super(key: key);
  final String noNota;

  @override
  State<DetailPesananScreen> createState() => _DetailPesananScreenState();
}

class _DetailPesananScreenState extends State<DetailPesananScreen> {
  Map<String, dynamic> detailOrder = {};
  Map<String, dynamic> dataLogin = {};

  final auth = AuthService();

  Future<Map<String, dynamic>> fetchDetailOrder(
      String id, String sessionId, String noNota) async {
    Map<String, dynamic> detailOrder = {};

    final responseDetailOrder = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/order/detail/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId&no_nota=$noNota'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/order/detail/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId&no_nota=$noNota'));
    if (responseDetailOrder.statusCode == 200) {
      print('fetchDetailOrder');
      final Map order = jsonDecode(responseDetailOrder.body);
      if (order['data'].isNotEmpty) {
        detailOrder = order['data'].first;
      }
    } else {
      print('Failed to load order');
    }
    return detailOrder;
  }

  Future<bool> gantiPengiriman(String id, String sessionId, String noNota,
      String ip, int idPengiriman) async {
    final responseGantiPengiriman = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/order/ubah-pengiriman/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId&ip=$ip&no_nota=$noNota&pengiriman_id=$idPengiriman'));

    if (responseGantiPengiriman.statusCode == 200) {
      print('send ganti pengiriman');
      final Map gantiPengiriman = jsonDecode(responseGantiPengiriman.body);
      if (gantiPengiriman['data'].isNotEmpty) {
        print(gantiPengiriman['data'].first);
        return true;
      }
    } else {
      print('Failed to ganti pengiriman');
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    AuthService().strDataLogin.then((dataLoginx) {
      var dataLoginy = jsonDecode(dataLoginx.toString());
      fetchDetailOrder(dataLoginy['MKid'], dataLoginy['sess_id'], widget.noNota)
          .then((value) {
        setState(() {
          detailOrder = value;
          dataLogin = dataLoginy;
          // print(detailOrder);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Pesanan'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          // future: detailOrder,
          initialData: detailOrder,
          builder: (context, snapshot) {
            if (detailOrder.isNotEmpty) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Order',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Nomor Nota'),
                              Text(detailOrder['no_order']),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tanggal Order'),
                              Text(detailOrder['tgl_order']),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(
                                    flex: 1, child: Text('Status Order')),
                                Flexible(
                                    flex: 1,
                                    child: Text(
                                      detailOrder['status_order_txt'],
                                      textAlign: TextAlign.end,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.only(left: 12),
                      color: Theme.of(context).colorScheme.background,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Log Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                splashRadius: 18,
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.keyboard_arrow_right),
                                onPressed: () {
                                  print(widget.noNota);
                                  Navigator.of(context).push(_createRoute(
                                      LogStatusOrder(
                                        noNota: widget.noNota,
                                      ),
                                      slideDirection.toLeft));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.background,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 4),
                            child: Text(
                              'Detail Pengiriman',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              detailOrder['isDiambil'] == '0'
                                  ? Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Html(
                                            data: detailOrder[
                                                'alamat_pengiriman']),
                                      ),
                                    )
                                  : Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12.0,
                                          horizontal: 12,
                                        ),
                                        child: Text(detailOrder[
                                            'isDiambil_kota_tujuan']),
                                      ),
                                    ),
                              if (detailOrder['bisa_ubah_pengiriman'])
                                Material(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0)),
                                  // width: 38,
                                  // height: 38,
                                  // padding: const EdgeInsets.only(right: 12),
                                  child: IconButton(
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
                                                          color:
                                                              Colors.black54),
                                                ),
                                              ),
                                              ...detailOrder[
                                                      'data_ubah_pengiriman']
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
                                                    onTap: () async {
                                                      String ip =
                                                          await AuthService
                                                              .getIPAddress();
                                                      gantiPengiriman(
                                                        dataLogin['MKid'],
                                                        dataLogin['sess_id'],
                                                        widget.noNota,
                                                        ip,
                                                        jenisPengiriman[
                                                            'pengiriman_id'],
                                                      ).then(
                                                        (gantiPengiriman) {
                                                          if (gantiPengiriman) {
                                                            Navigator.pop(
                                                                context);
                                                            fetchDetailOrder(
                                                              dataLogin['MKid'],
                                                              dataLogin[
                                                                  'sess_id'],
                                                              widget.noNota,
                                                            ).then(
                                                              (reloadOrder) {
                                                                setState(() {
                                                                  detailOrder =
                                                                      reloadOrder;
                                                                  // print(reloadOrder);
                                                                });
                                                              },
                                                            );
                                                          }
                                                        },
                                                      );
                                                    },
                                                    title: Text(jenisPengiriman[
                                                        'pengiriman_txt']),
                                                    trailing: jenisPengiriman[
                                                            'isSelect']
                                                        ? Icon(
                                                            Icons.check,
                                                            color: Theme.of(
                                                                    context)
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
                                    splashRadius: 24,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      color: Theme.of(context).colorScheme.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Biaya Pengiriman dan Penanganan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Berat'),
                                Text(detailOrder['berat_txt'])
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Kota'),
                                Flexible(
                                  child: Text(
                                    detailOrder['isDiambil_kota_tujuan'],
                                    textAlign: TextAlign.end,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Ongkos Kirim dan Penanganan'),
                                Flexible(
                                  child: Text(
                                    'Rp ' +
                                        detailOrder[
                                            'ongkos_kirim_dan_penyiapan'],
                                    textAlign: TextAlign.end,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).colorScheme.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Text(
                              'Detail Produk',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...detailOrder['data_order']!.map((produk) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Column(
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  produk['produk_nama'],
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  produk['produk_kode'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption,
                                                ),
                                                const SizedBox(height: 6),
                                                Text('Rp ' + produk['harga']),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          // padding: const EdgeInsets.symmetric(
                                          //     horizontal: 8),
                                          alignment: Alignment.centerRight,
                                          width: 40,
                                          // height: double.infinity,
                                          // color: Colors.red,
                                          child: Text('x' + produk['jumlah']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal'),
                                Text(detailOrder['total_harga_barang']),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Theme.of(context).colorScheme.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8.0),
                            child: Text(
                              'Detail Pembayaran',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal Produk'),
                                Text(detailOrder['total_harga_barang'])
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Diskon ' +
                                    (detailOrder['diskon_txt']
                                            .toString()
                                            .isNotEmpty
                                        ? '(' + detailOrder['diskon_txt'] + ')'
                                        : '')),
                                Text('- ' + detailOrder['diskon_rp'])
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('PPN ' +
                                    (detailOrder['ppn_txt']
                                            .toString()
                                            .isNotEmpty
                                        ? '(' + detailOrder['ppn_txt'] + ')'
                                        : '')),
                                Text('Rp ' + detailOrder['ppn_rp'])
                              ],
                            ),
                          ),
                          if (detailOrder['biaya_pembayaran'])
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Biaya Pembayaran'),
                                  Text(detailOrder['biaya_pembayaran_rp'])
                                ],
                              ),
                            ),
                          if (detailOrder['isDiambil'] == '0')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Ongkos Kirim'),
                                  Text('Rp ' +
                                      detailOrder['ongkos_kirim_dan_penyiapan'])
                                ],
                              ),
                            ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total'),
                                Text(
                                  'Rp ' + detailOrder['total_harus_dibayarkan'],
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      color: Theme.of(context).colorScheme.background,
                      child: Html(data: detailOrder['data_payment_txt']),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Theme.of(context).colorScheme.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8.0),
                            child: Text(
                              'Download Dokumen',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (detailOrder['dokumen_invoice_url'] != '#')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (await canLaunch(
                                      detailOrder['dokumen_invoice_url'])) {
                                    await launch(
                                      detailOrder['dokumen_invoice_url'],
                                    );
                                  } else {
                                    throw 'Could not launch ${detailOrder['dokumen_invoice_url']}';
                                  }
                                },
                                child: Text(detailOrder['dokumen_invoice']),
                              ),
                            ),
                          if (detailOrder['dokumen_proforma_url'] != '#')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (await canLaunch(
                                      detailOrder['dokumen_proforma_url'])) {
                                    await launch(
                                      detailOrder['dokumen_proforma_url'],
                                    );
                                  } else {
                                    throw 'Could not launch ${detailOrder['dokumen_proforma_url']}';
                                  }
                                },
                                child: Text(detailOrder['dokumen_proforma']),
                              ),
                            ),
                          if (detailOrder['dokumen_quotation_url'] != '#')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (await canLaunch(
                                      detailOrder['dokumen_quotation_url'])) {
                                    await launch(
                                      detailOrder['dokumen_quotation_url'],
                                    );
                                  } else {
                                    throw 'Could not launch ${detailOrder['dokumen_quotation_url']}';
                                  }
                                },
                                child: Text(detailOrder['dokumen_quotation']),
                              ),
                            ),
                          if (detailOrder['download_detail_produk_url'] != '#')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (await canLaunch(detailOrder[
                                      'download_detail_produk_url'])) {
                                    await launch(
                                      detailOrder['download_detail_produk_url'],
                                    );
                                  } else {
                                    throw 'Could not launch ${detailOrder['download_detail_produk_url']}';
                                  }
                                },
                                child:
                                    Text(detailOrder['download_detail_produk']),
                              ),
                            ),
                          if (detailOrder['ada_dokumen_msg']
                              .toString()
                              .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2.0),
                              child: Text(detailOrder['ada_dokumen_msg']),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
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
}
