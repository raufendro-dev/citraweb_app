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
  List device = [];
  Future cekgaransi() async {
    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "ip": await AuthService.getIPAddress(),
      "devices": ""
    });
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api//cekgaransi/'),
      body: bodyPost,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: const Text('Cek Garansi'),
      ),
    );
  }
}
