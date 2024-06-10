// ignore_for_file: avoid_print

import 'dart:convert';
import 'register_screen_personal.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:mikrotik/services/auth_service.dart';
import '../models/dropdown_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectedOption = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pendaftaran Member'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 50, bottom: 20),
              child: Text(
                "Pilih Tipe Akun",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RadioListTile(
                    title: Text('Personal'),
                    value: 'Personal',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Perusahaan'),
                    value: 'Perusahaan',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (selectedOption == "Personal") {
                          print("personal");
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const RegisterPersonalScreen(),
                              ));
                        } else if (selectedOption == "Perusahaan") {
                          print("perusahaan");
                        }
                      },
                      child: Text("Lanjutkan"))
                ],
              ),
            )
          ],
        ));
  }
}
