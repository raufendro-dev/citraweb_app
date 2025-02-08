// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

class LogStatusRma extends StatefulWidget {
  const LogStatusRma({Key? key, required this.noRma}) : super(key: key);

  final String noRma;

  @override
  State<LogStatusRma> createState() => _LogStatusRmaState();
}

class _LogStatusRmaState extends State<LogStatusRma> {
  final _keyLog = GlobalKey<FormState>();
  Future<List<Map<String, dynamic>>>? futureLogs;

  final auth = AuthService();
  final controllerPesan = TextEditingController();

  Future<List<Map<String, dynamic>>> fetchLogs() async {
    final List<Map<String, dynamic>> listLogs = [];

    final responseLogs = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/rma/log/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        (await auth.idUser) +
        '&sess_id=' +
        (await auth.sessId) +
        '&no_RMA=${widget.noRma}'));
    if (responseLogs.statusCode == 200) {
      print('fetchLogs');
      final Map logs = jsonDecode(responseLogs.body);
      if (logs['data'].isNotEmpty) {
        for (var infoLogs in logs['data']) {
          listLogs.add(infoLogs);
        }
      }
    } else {
      print('Failed to load rma log');
      print(Config.baseUrlApi +
          'app-api/rma/log/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
          (await auth.idUser) +
          '&sess_id=' +
          (await auth.sessId) +
          '&no_RMA=${widget.noRma}');
    }
    return listLogs;
  }

  Future<Map<String, dynamic>> kirimLog() async {
    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "iduser": (await auth.idUser),
      "sess_id": (await auth.sessId),
      "no_RMA": widget.noRma,
      "ip": await AuthService.getIPAddress(),
      "pesan": controllerPesan.text,
    });
    print(bodyPost);
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/rma/kirim-log/'),
      body: bodyPost,
    );
    print(res.body);
    if (res.statusCode == 200) {
      print(jsonDecode(res.body)['data'].first);
      return jsonDecode(res.body)['data'].first;
    }
    return {"kirim_log": false, "msg": "Terjadi kesalahan saat pendaftaran"};
  }

  @override
  void initState() {
    super.initState();
    futureLogs = fetchLogs();
  }

  Stream<List<Map<String, dynamic>>> createDataStream() async* {
    while (true) {
      try {
        final data = await fetchLogs();
        yield data;
        await Future.delayed(Duration(seconds: 5)); // Adjust polling interval
      } catch (e) {
        // Handle errors gracefully (e.g., retry logic)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Status RMA'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: createDataStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final logs = snapshot.data!;
              if (logs.isEmpty) {
                return const Center(child: Text('Tidak ada log'));
              }
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).colorScheme.background,
                    child: Form(
                      key: _keyLog,
                      child: Column(
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            controller: controllerPesan,
                            maxLines: 3,
                            decoration: InputDecoration(
                              label: const Text('Pesan Anda'),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              // hintText: 'Pesan Anda ...',
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                            ),
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Pesan tidak boleh kosong'
                                  : null;
                            },
                          ),
                          ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (_keyLog.currentState!.validate()) {
                                  kirimLog().then((value) {
                                    if (value['kirim_log']) {
                                      _keyLog.currentState!.reset();
                                      controllerPesan.clear();
                                      setState(() {
                                        futureLogs = fetchLogs();
                                      });
                                    }
                                    showDialog<void>(
                                      context: context,
                                      useRootNavigator: false,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Html(
                                            data: value['msg'],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('close'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  });
                                }
                              },
                              child: const Text('Kirim'))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    child: const Divider(
                      height: 0,
                      thickness: .5,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.zero,
                      color: Theme.of(context).colorScheme.background,
                      child: ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (contex, index) => Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Html(
                                    data: logs[index]['user_nama'],
                                    style: {
                                      "*": Style(margin: EdgeInsets.zero),
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Text(
                                    logs[index]['user_tgl'],
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ),
                                const Divider(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Html(data: logs[index]['user_status']),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Html(
                                    data: logs[index]['user_pesan'],
                                    onLinkTap: (String? url,
                                        RenderContext context,
                                        Map<String, String> attributes,
                                        dom.Element? element) async {
                                      await launchUrl(Uri.parse(url!),
                                          mode: LaunchMode.externalApplication);
                                      //open URL in webview, or launch URL in browser, or any other logic here
                                      // if (await canLaunch(url!)) {
                                      //   await launch(
                                      //     url,
                                      //   );
                                      // } else {
                                      //   throw 'Could not launch $url';
                                      // }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
