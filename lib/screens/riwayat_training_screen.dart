// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/screens/detail_order_training_screen.dart';
import 'package:mikrotik/services/auth_service.dart';
import '../main.dart';

class RiwayatTrainingScreen extends StatefulWidget {
  const RiwayatTrainingScreen({Key? key}) : super(key: key);

  @override
  State<RiwayatTrainingScreen> createState() => _RiwayatTrainingScreenState();
}

class _RiwayatTrainingScreenState extends State<RiwayatTrainingScreen> {
  Map<String, dynamic> dataLogin = {};

  Future<List<Map<String, dynamic>>>? futureTraining;

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

  @override
  void initState() {
    super.initState();

    AuthService().strDataLogin.then((value) {
      setState(() {
        dataLogin = jsonDecode(value.toString());
        futureTraining = fetchTrainings(jsonDecode(value.toString())['MKid'],
            jsonDecode(value.toString())['sess_id']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Training'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureTraining,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final trainings = snapshot.data!;
            if (trainings.isNotEmpty) {
              return ListView.separated(
                itemCount: trainings.length,
                separatorBuilder: (contex, index) => const Divider(
                  indent: 12,
                  endIndent: 12,
                ),
                itemBuilder: (context, index) => ListTile(
                  onTap: () {
                    print('trining');

                    Navigator.of(context).push(_createRoute(
                        DetailOrderTrainingScreen(
                            idTraining: trainings[index]['id_training_detail']),
                        slideDirection.toLeft));
                  },
                  tileColor: Theme.of(context).colorScheme.background,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  title: Text(trainings[index]['nama']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trainings[index]['kota']),
                      ...trainings[index]['tanggal'].split(',').map((value) {
                        return Text(
                            value[0] == ' ' ? value.substring(1) : value);
                      }),
                      Text('Status Pendaftaran: ' +
                          trainings[index]['status_daftar']),
                      Text('Status Pembayaran: ' +
                          trainings[index]['status_bayar']),
                    ],
                  ),
                  dense: true,
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
