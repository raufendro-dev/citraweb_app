import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/services/auth_service.dart';

class CekgaransiScreen extends StatefulWidget {
  const CekgaransiScreen({Key? key}) : super(key: key);

  @override
  _CekgaransiScreenState createState() => _CekgaransiScreenState();
}

class _CekgaransiScreenState extends State<CekgaransiScreen> {
  String s1 = "";
  String s2 = "";
  String s3 = "";
  String s4 = "";
  String s5 = "";
  final List<TextEditingController> controllers =
      List.generate(5, (_) => TextEditingController());
  List<String> device = [];
  var dataList;
  final regexp = RegExp(r"[@#\$%&]");
  Future<bool> cekgaransi(dev) async {
    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "ip": await AuthService.getIPAddress(),
      "devices": dev
    });
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api//cekgaransi/'),
      body: bodyPost,
    );
    var data = jsonDecode(res.body);
    print(data['data']);
    setState(() {
      dataList = data['data'];
    });
    return true;
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent user from dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Center content horizontally
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text('Loading...'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Garansi'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Silahkan input nomor serial number',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
            // Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Column(
            //       children: [
            //         for (int i = 1; i <= 5; i++)
            //           Padding(
            //             padding: const EdgeInsets.symmetric(vertical: 10),
            //             child: buildTextField(i),
            //           ),
            //       ],
            //     )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  for (int i = 1; i <= 5; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: buildTextField(i),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      showLoadingDialog();
                      // Access the text from each controller
                      for (int i = 0; i < controllers.length; i++) {
                        final text = controllers[i].text;
                        List<String> _temp = [];
                        if (controllers[i].text != "") {
                          device.add(text);
                          print("Text Field $i: $text");
                          // if (i == 0) {
                          //   setState(() {
                          //     s1 = text;
                          //   });
                          // }
                          // if (i == 1) {
                          //   setState(() {
                          //     s2 = text;
                          //   });
                          // }
                          // if (i == 2) {
                          //   setState(() {
                          //     s3 = text;
                          //   });
                          // }
                          // if (i == 3) {
                          //   setState(() {
                          //     s4 = text;
                          //   });
                          // }
                          // if (i == 4) {
                          //   setState(() {
                          //     s5 = text;
                          //   });
                          // }
                        }
                      }
                      print(device
                          .toString()
                          .replaceAll(", ", "\n")
                          .replaceAll("]", "")
                          .replaceAll("[", ""));
                      var dev = await device
                          .toString()
                          .replaceAll(", ", "\n")
                          .replaceAll("]", "")
                          .replaceAll("[", "");
                      await cekgaransi(dev);

                      device.clear();
                      Navigator.pop(context);
                      await showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildListViewBottomSheet(),
                      );
                    },
                    child: Text('Cek Garansi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListViewBottomSheet() {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.7, // Adjust height as needed
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          final item = dataList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Text(
                "Serial Number: ${item['search_id']}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              subtitle: Text(
                  "Type: ${item['type']}\nRelease Date: ${item['release_date']}\nWarranty: ${item['warranty_status']}"),
            ),
          );
        },
      ),
    );
  }

  Widget buildTextField(int index) {
    final controller = controllers[index - 1];

    // Add listener to the controller to handle text changes
    controller.addListener(() {
      final text = controller.text;
      final filteredText = text.replaceAll(regexp, '');
      if (text != filteredText) {
        controller.text = filteredText;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: filteredText.length),
        );
      }
    });

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Serial Number $index',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        print(value);
      },
    );
  }
}
