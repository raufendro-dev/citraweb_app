// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/main.dart';
import 'package:mikrotik/screens/detail_rma_screen.dart';
import 'package:mikrotik/screens/form_rma.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:mikrotik/widgets/shimmer_widget.dart';

class RiwayatRmaScreen extends StatefulWidget {
  const RiwayatRmaScreen({Key? key}) : super(key: key);

  @override
  State<RiwayatRmaScreen> createState() => _RiwayatRmaScreenState();
}

class _RiwayatRmaScreenState extends State<RiwayatRmaScreen> {
  int curentPage = 1;
  int totalPage = 1;

  Map<String, dynamic> dataLogin = {};

  Future<List<Map<String, dynamic>>>? futureRMA;

  Future<List<Map<String, dynamic>>> fetchRMA(String id, String sessionId,
      {bool loadMore = false, List listLama = const []}) async {
    final List<Map<String, dynamic>> listRMA = [];

    final page = loadMore ? '&page=${curentPage + 1}' : '&page=$curentPage';
    final responseRMA = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/rma/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId$page'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/rma/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId$page'));
    if (responseRMA.statusCode == 200) {
      print('fetchrma');
      final Map rma = jsonDecode(responseRMA.body);
      if (rma['data'].isNotEmpty) {
        // print(rma['data']);
        for (var infoRMA in rma['data']) {
          listRMA.add(infoRMA);
        }

        if (loadMore) {
          setState(() {
            curentPage += 1;
            totalPage = rma['totalpage'];
          });
        } else {
          setState(() {
            totalPage = rma['totalpage'];
          });
        }
      }
    } else {
      print('Failed to load rma');
    }

    if (loadMore) {
      print('loadMore');
      return (listLama as List<Map<String, dynamic>>) + listRMA;
    } else {
      return listRMA;
    }
  }

  @override
  void initState() {
    super.initState();

    AuthService().strDataLogin.then((value) {
      setState(() {
        dataLogin = jsonDecode(value.toString());
        futureRMA = fetchRMA(jsonDecode(value.toString())['MKid'],
            jsonDecode(value.toString())['sess_id']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat RMA'), actions: [
        IconButton(
          splashRadius: 24,
          onPressed: () {
            Navigator.of(context)
                .push(_createRoute(const FormRma(), slideDirection.toLeft))
                .then((value) {
              if (value ?? false) {
                AuthService().strDataLogin.then((value) {
                  setState(() {
                    futureRMA = fetchRMA(jsonDecode(value.toString())['MKid'],
                        jsonDecode(value.toString())['sess_id']);
                  });
                });
              }
            });
          },
          icon: const Icon(Icons.add),
        )
      ]),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureRMA,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final rma = snapshot.data!;
            if (rma.isNotEmpty) {
              return NotificationListener<ScrollEndNotification>(
                onNotification: (ScrollEndNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    if (curentPage < totalPage) {
                      // setState(() {
                      futureRMA = fetchRMA(
                        dataLogin['MKid'],
                        dataLogin['sess_id'],
                        loadMore: true,
                        listLama: rma,
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
                  itemCount:
                      curentPage < totalPage ? rma.length + 1 : rma.length,
                  separatorBuilder: (contex, index) => const Divider(
                    indent: 12,
                    endIndent: 12,
                  ),
                  itemBuilder: (context, index) => curentPage < totalPage &&
                          index == rma.length
                      ? ListTile(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              ShimmerWidget.rectangular(width: 110, height: 14),
                              SizedBox(height: 4),
                              ShimmerWidget.rectangular(width: 160, height: 10),
                              SizedBox(height: 4),
                              ShimmerWidget.rectangular(width: 60, height: 10),
                            ],
                          ),
                          // subtitle: Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: const [
                          //     ShimmerWidget.rectangular(height: 12),
                          //     SizedBox(height: 4),
                          //     ShimmerWidget.rectangular(height: 12)
                          //   ],
                          // ),
                          trailing: const ShimmerWidget.rectangular(
                              width: 70, height: 18),
                        )
                      : ListTile(
                          onTap: () {
                            print('RMA');

                            Navigator.of(context).push(_createRoute(
                                DetailRmaScreen(
                                  noRMA: rma[index]['no_RMA'],
                                ),
                                slideDirection.toLeft));
                          },
                          tileColor: Theme.of(context).colorScheme.background,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 12),
                          minVerticalPadding: 10,
                          title: Text(rma[index]['tgl_RMA']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ' + rma[index]['status_txt_RMA']),
                              Text('Pesan: ' + rma[index]['cuplikan_RMA']),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: Text(
                              rma[index]['no_RMA'],
                              textAlign: TextAlign.end,
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
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                color: Theme.of(context).colorScheme.background,
                child: const Text('Tidak terdapat training'));
          }
          return const Center(child: CircularProgressIndicator());
        },
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
}
