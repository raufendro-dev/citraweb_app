// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/services/auth_service.dart';

class DetailOrderTrainingScreen extends StatelessWidget {
  const DetailOrderTrainingScreen({Key? key, required this.idTraining})
      : super(key: key);
  final String idTraining;

  Future<Map<String, dynamic>> fetchDetailTraining() async {
    Map<String, dynamic> detailTraining = {};
    final auth = AuthService();

    final responseDetailTraining = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/training/user-training-detail/?key=0cc7da679bea04fea453c8062e06514d&iduser=${await auth.idUser}&sess_id=${await auth.sessId}&id_training_detail=$idTraining'));
    print(Uri.parse(Config.baseUrlApi +
        'app-api/training/user-training-detail/?key=0cc7da679bea04fea453c8062e06514d&iduser=${await auth.idUser}&sess_id=${await auth.sessId}&id_training_detail=$idTraining'));
    if (responseDetailTraining.statusCode == 200) {
      print('fetchDetailTraining');
      final Map training = jsonDecode(responseDetailTraining.body);
      if (training['data'].isNotEmpty) {
        detailTraining = training['data'].first;
      }
    } else {
      print('Failed to load training');
    }
    return detailTraining;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Training'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: fetchDetailTraining(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final training = snapshot.data!;
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    // height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                    // alignment: Alignment.center,
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelas Pelatihan',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Nama Training',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['tr_nama']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Tanggal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...training['tr_tanggal']
                                      .split(',')
                                      .map((value) {
                                    return Text(value[0] == ' '
                                        ? value.substring(1)
                                        : value);
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Kota',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['tr_kota']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Harga',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['tr_harga']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                    // alignment: Alignment.center,
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Peserta',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Nama Lengkap',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['user_nama']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'User Id',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['user_userid']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['user_email']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Perusahaan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['user_perusahaan']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Kota',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['user_kota']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Telp',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['user_telp']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Selular',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['user_selular']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                    // alignment: Alignment.center,
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pendaftaran',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Tanggal Daftar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['tgl_daftar']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const Text(':  '),
                            Expanded(
                              child: Text(training['status_daftar_txt']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
