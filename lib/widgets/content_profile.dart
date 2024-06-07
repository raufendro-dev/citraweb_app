// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/constant/custom_icons.dart';
import 'package:mikrotik/providers/profile_provider.dart';
import 'package:mikrotik/screens/detail_order_training_screen.dart';
import 'package:mikrotik/screens/detail_pesanan_screen.dart';
import 'package:mikrotik/screens/detail_rma_screen.dart';
import 'package:mikrotik/screens/edit_profile_screen.dart';
import 'package:mikrotik/screens/home_page_screen.dart';
import 'package:mikrotik/screens/riwayat_pesanan_screen.dart';
import 'package:mikrotik/screens/riwayat_rma_screen.dart';
import 'package:mikrotik/screens/riwayat_training_screen.dart';
import 'package:provider/provider.dart';
import 'package:mikrotik/providers/cart_provider.dart';
import 'package:mikrotik/screens/login_screen.dart';
import '../services/auth_service.dart';
import '../main.dart';

class ContentProfile extends StatefulWidget {
  const ContentProfile({Key? key}) : super(key: key);

  @override
  State<ContentProfile> createState() => _ContentProfileState();
}

class _ContentProfileState extends State<ContentProfile>
    with AutomaticKeepAliveClientMixin<ContentProfile> {
  final auth = AuthService();
  // bool isLogin = false;
  Map<String, dynamic> dataLogin = {};

  Future<Map<String, dynamic>> fetchProfile(String id, String sessionId) async {
    Map<String, dynamic> profileObj = {};

    final responseProfile = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/profil/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId'));
    if (responseProfile.statusCode == 200) {
      print('fetchProfile');
      final Map profil = jsonDecode(responseProfile.body);
      if (profil['data'].isNotEmpty) {
        // for (var infoProfile in profil['data']) {
        //   // profileObj.add(infoProfile);

        // }
        profileObj = profil['data'].first;
        print("tessss prof");
      }
    } else {
      print('Failed to load Profile');
    }
    return profileObj;
  }

  Future<List<Map<String, dynamic>>> fetchOrders(
      String id, String sessionId) async {
    final List<Map<String, dynamic>> listOrders = [];

    final responseOrders = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/order/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/order/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId'));
    if (responseOrders.statusCode == 200) {
      print('fetchOrders');
      final Map orders = jsonDecode(responseOrders.body);
      if (orders['data'].isNotEmpty) {
        // print(orders['data']);
        for (var infoOrders in orders['data']) {
          listOrders.add(infoOrders);
        }
      }
    } else {
      print('Failed to load Orders');
    }
    return listOrders;
  }

  Future<List<Map<String, dynamic>>> fetchTrainings(
      String id, String sessionId) async {
    final List<Map<String, dynamic>> listTraining = [];

    final responseTrainings = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/training/user-training/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/training/user-training/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId'));
    if (responseTrainings.statusCode == 200) {
      print('fetchTrainings');
      final Map trainings = jsonDecode(responseTrainings.body);
      if (trainings['data'].isNotEmpty) {
        // print(trainings['data']);
        for (var infoTrinings in trainings['data']) {
          listTraining.add(infoTrinings);
        }
      }
    } else {
      print('Failed to load trainings');
    }
    return listTraining;
  }

  Future<List<Map<String, dynamic>>> fetchRMA(
      String id, String sessionId) async {
    final List<Map<String, dynamic>> listRMA = [];

    final responseRMA = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/rma/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/rma/?key=0cc7da679bea04fea453c8062e06514d&iduser=$id&sess_id=$sessionId'));
    if (responseRMA.statusCode == 200) {
      print('fetchTrainings');
      final Map rma = jsonDecode(responseRMA.body);
      if (rma['data'].isNotEmpty) {
        // print(rma['data']);
        for (var infoRMA in rma['data']) {
          listRMA.add(infoRMA);
        }
      }
    } else {
      print('Failed to load rma');
    }
    return listRMA;
  }

  @override
  void initState() {
    super.initState();
    // isLogin = value;
    auth.strDataLogin.then((value) {
      print('datalogin');
      print(value);
      setState(() {
        dataLogin =
            value.toString().isNotEmpty ? jsonDecode(value.toString()) : {};
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    super.build(context);
    print('build profile');
    return FutureBuilder(
        future: auth.cekLogin(context),
        builder: (context, objFutureLogin) {
          if (objFutureLogin.hasData) {
            if (objFutureLogin.data == true) {
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: FutureBuilder<Map<String, dynamic>>(
                    future:
                        fetchProfile(dataLogin['MKid'], dataLogin['sess_id']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final profil = snapshot.data!;
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ListTile(
                                dense: false,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(12, 14, 12, 12),
                                tileColor:
                                    Theme.of(context).colorScheme.primary,
                                leading: SizedBox(
                                  width: 60,
                                  height: 100,
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: const Icon(
                                      Icons.person,
                                      size: 42,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  profil['nama'],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profil['email'],
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background),
                                    ),
                                    Text(
                                      profil['selular'],
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  // color: Colors.white,
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    splashRadius: 24,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfilScreen(
                                            profileObj: profil,
                                          ),
                                        ),
                                      ).then(
                                        (value) {
                                          if (value) {
                                            setState(() {});
                                          }
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.mode_edit_outlined),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.zero,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 12, 4, 12),
                                color: Theme.of(context).colorScheme.background,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.event_note,
                                          size: 22,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('Pesanan Saya'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 22,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            primary: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            alignment: Alignment.center,
                                          ),
                                          label: const Text(
                                            'Riwayat Pesanan',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal),
                                          ),
                                          icon: Container(
                                              padding: EdgeInsets.zero,
                                              width: 14,
                                              child: const Icon(
                                                  Icons.keyboard_arrow_right)),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                _createRoute(
                                                    const RiwayatPesananScreen(),
                                                    slideDirection.toLeft));
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 0,
                                thickness: 1,
                                // indent: 12,
                                // endIndent: 12,
                              ),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: fetchOrders(
                                    dataLogin['MKid'], dataLogin['sess_id']),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final orders = snapshot.data!;
                                    if (orders.isNotEmpty) {
                                      return Column(
                                        children: List.generate(
                                          orders.length < 5 ? orders.length : 5,
                                          (index) => Column(
                                            children: [
                                              ListTile(
                                                onTap: () {
                                                  print('orders');

                                                  Navigator.of(context).push(
                                                      _createRoute(
                                                          DetailPesananScreen(
                                                              noNota: orders[
                                                                      index]
                                                                  ['no_nota']),
                                                          slideDirection
                                                              .toLeft));
                                                },
                                                tileColor: Theme.of(context)
                                                    .colorScheme
                                                    .background,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 0,
                                                        horizontal: 12),
                                                minVerticalPadding: 12,
                                                title: Text(
                                                    orders[index]['tgl_order']),
                                                subtitle: Text(
                                                  orders[index]['status_txt'],
                                                ),
                                                // isThreeLine: true,
                                                trailing: SizedBox(
                                                  width: 120,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        orders[index]
                                                            ['no_nota'],
                                                        textAlign:
                                                            TextAlign.end,
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        'Rp ' +
                                                            orders[index][
                                                                'transaksi_rp'],
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                dense: true,
                                              ),
                                              if (index != 4)
                                                const Divider(
                                                  height: 0,
                                                  indent: 12,
                                                  endIndent: 12,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 24, horizontal: 0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        child:
                                            const Text('Tidak terdapat order'));
                                  }
                                  return Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 0),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 12, 4, 12),
                                color: Theme.of(context).colorScheme.background,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          CustomIcons.training,
                                          size: 22,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('Training Saya'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 22,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            primary: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            alignment: Alignment.center,
                                          ),
                                          label: const Text(
                                            'Riwayat Training',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal),
                                          ),
                                          icon: Container(
                                              padding: EdgeInsets.zero,
                                              width: 14,
                                              child: const Icon(
                                                  Icons.keyboard_arrow_right)),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                _createRoute(
                                                    const RiwayatTrainingScreen(),
                                                    slideDirection.toLeft));
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 0,
                                thickness: 1,
                                // indent: 12,
                                // endIndent: 12,
                              ),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: fetchTrainings(
                                    dataLogin['MKid'], dataLogin['sess_id']),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final trainings = snapshot.data!;
                                    if (trainings.isNotEmpty) {
                                      return Column(
                                        children: List.generate(
                                          trainings.length < 5
                                              ? trainings.length
                                              : 5,
                                          (index) => Column(
                                            children: [
                                              ListTile(
                                                onTap: () {
                                                  print('trining');

                                                  Navigator.of(context).push(_createRoute(
                                                      DetailOrderTrainingScreen(
                                                          idTraining: trainings[
                                                                  index][
                                                              'id_training_detail']),
                                                      slideDirection.toLeft));
                                                },
                                                tileColor: Theme.of(context)
                                                    .colorScheme
                                                    .background,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 6,
                                                  horizontal: 12,
                                                ),
                                                title: Text(
                                                    trainings[index]['nama']),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(trainings[index]
                                                        ['kota']),
                                                    ...trainings[index]
                                                            ['tanggal']
                                                        .split(',')
                                                        .map((value) {
                                                      return Text(value[0] ==
                                                              ' '
                                                          ? value.substring(1)
                                                          : value);
                                                    }),
                                                    Text('Status Pendaftaran: ' +
                                                        trainings[index]
                                                            ['status_daftar']),
                                                    Text('Status Pembayaran: ' +
                                                        trainings[index]
                                                            ['status_bayar']),
                                                  ],
                                                ),
                                                dense: true,
                                              ),
                                              if (index != 4)
                                                const Divider(
                                                  height: 0,
                                                  indent: 12,
                                                  endIndent: 12,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 24, horizontal: 0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        child: const Text(
                                            'Tidak terdapat training'));
                                  }
                                  return Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 0),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 12, 4, 12),
                                color: Theme.of(context).colorScheme.background,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.tools,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('RMA'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 22,
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            primary: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            alignment: Alignment.center,
                                          ),
                                          label: const Text(
                                            'Riwayat RMA',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal),
                                          ),
                                          icon: Container(
                                              padding: EdgeInsets.zero,
                                              width: 14,
                                              child: const Icon(
                                                  Icons.keyboard_arrow_right)),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                _createRoute(
                                                    const RiwayatRmaScreen(),
                                                    slideDirection.toLeft));
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 0,
                                thickness: 1,
                                // indent: 12,
                                // endIndent: 12,
                              ),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: fetchRMA(
                                    dataLogin['MKid'], dataLogin['sess_id']),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final rma = snapshot.data!;
                                    if (rma.isNotEmpty) {
                                      return Column(
                                        children: List.generate(
                                          rma.length < 5 ? rma.length : 5,
                                          (index) => Column(
                                            children: [
                                              ListTile(
                                                onTap: () {
                                                  print('RMA');

                                                  Navigator.of(context).push(
                                                      _createRoute(
                                                          DetailRmaScreen(
                                                            noRMA: rma[index]
                                                                ['no_RMA'],
                                                          ),
                                                          slideDirection
                                                              .toLeft));
                                                },
                                                tileColor: Theme.of(context)
                                                    .colorScheme
                                                    .background,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 0,
                                                        horizontal: 12),
                                                minVerticalPadding: 10,
                                                title:
                                                    Text(rma[index]['tgl_RMA']),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Status: ' +
                                                        rma[index]
                                                            ['status_txt_RMA']),
                                                    Text('Pesan: ' +
                                                        rma[index]
                                                            ['cuplikan_RMA']),
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
                                              if (index != 4)
                                                const Divider(
                                                  height: 0,
                                                  indent: 12,
                                                  endIndent: 12,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 24, horizontal: 0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        child:
                                            const Text('Tidak terdapat order'));
                                  }
                                  return Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 0),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 18),
                                child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await AuthService()
                                          .logout()
                                          .then((isLogout) {
                                        if (isLogout) {
                                          cartProvider.resetCart();
                                          profileProvider.setIsLogin(false);

                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                            HomePageScreen.routeName,
                                            (Route<dynamic> route) => false,
                                          );
                                        }
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                    icon: const Icon(Icons.logout),
                                    label: const Text('Keluar')),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    }),
              );
            } else {
              return Center(
                child: ElevatedButton(
                    onPressed: () {
                      print('log');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => LoginScreen(),
                        ),
                      ).then((isLogin) async {
                        if (isLogin) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            HomePageScreen.routeName,
                            (Route<dynamic> route) => false,
                            arguments: 4,
                          );
                        } else {}
                      });
                    },
                    child: const Text('Login')),
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        });
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
