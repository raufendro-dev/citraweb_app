// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/services/auth_service.dart';

class LupaPasswordScreen extends StatelessWidget {
  LupaPasswordScreen({Key? key}) : super(key: key);
  final TextEditingController _emailCOntroller = TextEditingController();
  final TextEditingController _userNameCOntroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<Map<String, dynamic>> resetPassword() async {
    var bodyPost = jsonEncode({
      "key": "0cc7da679bea04fea453c8062e06514d",
      "ip": await AuthService.getIPAddress(),
      "userid": _userNameCOntroller.text,
      "email": _emailCOntroller.text,
    });
    print(bodyPost);
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/login/lupapassword/'),
      body: bodyPost,
    );
    print(res.body);
    if (res.statusCode == 200) {
      print(jsonDecode(res.body)['data'].first);
      return jsonDecode(res.body)['data'].first;
    }
    return {"reset": false, "msg": "Terjadi kesalahan saat pendaftaran"};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
        child: Form(
          key: _formKey,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailCOntroller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  // label: Text('Email'),
                  contentPadding: const EdgeInsets.all(8),
                  hintText: 'user@mail.com',
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary)),
                ),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'email kosong';
                  }
                  if (!val.contains('@')) {
                    return 'email salah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _userNameCOntroller,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  // label: Text('Email'),
                  contentPadding: const EdgeInsets.all(8),
                  hintText: 'username',
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary)),
                ),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'username kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (_formKey.currentState!.validate()) {
                    resetPassword().then((value) {
                      if (value['reset']) {
                        _formKey.currentState!.reset();
                        _emailCOntroller.text = '';
                        _userNameCOntroller.text = '';
                      } else {}

                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
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
                child: const Text('Reset Paswword'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
