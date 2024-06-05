// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/screens/detail_pesanan_screen.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:mikrotik/widgets/shimmer_widget.dart';

import 'package:mikrotik/main.dart';

class OrderTabContent extends StatefulWidget {
  const OrderTabContent({Key? key, required this.idStatus}) : super(key: key);
  final int idStatus;

  @override
  State<OrderTabContent> createState() => _OrderTabContentState();
}

class _OrderTabContentState extends State<OrderTabContent>
    with AutomaticKeepAliveClientMixin<OrderTabContent> {
  Map<String, dynamic> dataLogin = {};
  int curentPage = 1;
  int totalPage = 1;

  Future<List<Map<String, dynamic>>>? futureOrders;

  Future<List<Map<String, dynamic>>> fetchOrders(String id, String sessionId,
      {bool loadMore = false, List listLama = const []}) async {
    final List<Map<String, dynamic>> listOrders = [];

    final status = widget.idStatus == -1 ? '' : '&status=${widget.idStatus}';
    final page = loadMore ? '&page=${curentPage + 1}' : '&page=$curentPage';

    final responseOrders = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/order/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId$status$page'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/order/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId$status$page'));

    if (responseOrders.statusCode == 200) {
      print('fetchOrders');
      final Map orders = jsonDecode(responseOrders.body);
      if (orders['data'].isNotEmpty) {
        // print(orders['data']);
        for (var infoOrders in orders['data']) {
          listOrders.add(infoOrders);
        }

        if (loadMore) {
          setState(() {
            curentPage += 1;
            totalPage = orders['totalpage'];
          });
        } else {
          setState(() {
            totalPage = orders['totalpage'];
          });
        }
      } else {
        print('data kosong');
      }
    } else {
      print('Failed to load Orders');
    }

    if (loadMore) {
      print('loadMore');
      return (listLama as List<Map<String, dynamic>>) + listOrders;
    } else {
      print('first load');
      print(listOrders);
      return listOrders;
    }
  }

  @override
  void initState() {
    super.initState();

    AuthService().strDataLogin.then((value) {
      print('datalogin');
      print(value);
      setState(() {
        dataLogin =
            value.toString().isNotEmpty ? jsonDecode(value.toString()) : {};
        futureOrders = fetchOrders(jsonDecode(value.toString())['MKid'],
            jsonDecode(value.toString())['sess_id']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build order tab ${widget.idStatus}');
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureOrders,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final orders = snapshot.data!;
          if (orders.isNotEmpty) {
            return NotificationListener<ScrollEndNotification>(
              onNotification: (ScrollEndNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  if (curentPage < totalPage) {
                    // setState(() {
                    futureOrders = fetchOrders(
                      dataLogin['MKid'],
                      dataLogin['sess_id'],
                      loadMore: true,
                      listLama: orders,
                    ).then((value) {
                      setState(() {});
                      return value;
                    });
                    // });
                  }
                  print(curentPage);
                  return true;
                } else {
                  return false;
                }
              },
              child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                  height: 18,
                  thickness: 1,
                  indent: 12,
                  endIndent: 12,
                ),
                itemCount:
                    curentPage < totalPage ? orders.length + 1 : orders.length,
                itemBuilder: (context, index) => curentPage < totalPage &&
                        index == orders.length
                    ? ListTile(
                        tileColor: Theme.of(context).colorScheme.background,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        title: const ShimmerWidget.rectangular(height: 12),
                        subtitle: const ShimmerWidget.rectangular(height: 8),
                        trailing: SizedBox(
                          width: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              ShimmerWidget.rectangular(
                                height: 12,
                                width: 120,
                              ),
                              SizedBox(height: 8),
                              ShimmerWidget.rectangular(
                                height: 12,
                                width: 80,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListTile(
                        onTap: () {
                          print('orders');

                          Navigator.of(context).push(_createRoute(
                              DetailPesananScreen(
                                  noNota: orders[index]['no_nota']),
                              slideDirection.toLeft));
                        },
                        tileColor: Theme.of(context).colorScheme.background,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        title: Text(
                          orders[index]['no_nota'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orders[index]['tgl_order']),
                            Text(orders[index]['status_txt']),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rp ' + orders[index]['transaksi_rp'],
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              const SizedBox(height: 6),
                              if (orders[index]['status'] == 3.toString())
                                SizedBox(
                                  height: 24,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(4),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'Konfirmasi',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                )
                            ],
                          ),
                        ),
                        dense: true,
                      ),
              ),
            );
          }
          return Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
              color: Theme.of(context).colorScheme.background,
              child: const Text('Tidak terdapat order'));
        }
        return Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
          color: Theme.of(context).colorScheme.background,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
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
