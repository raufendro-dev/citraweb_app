// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mikrotik/providers/profile_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../mixins/login_validation_mixin.dart';

class FormBloc with ValidationMixin {
  final _email = BehaviorSubject<String>();
  final _userid = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _errorMessage = BehaviorSubject<String>();

  // getters: Changers
  Function(String) get changeEmail {
    addError('');
    return _email.sink.add;
  }

  Function(String) get changeUserId {
    addError('');
    return _userid.sink.add;
  }

  Function(String) get changePassword {
    addError('');
    return _password.sink.add;
  }

  Function(String) get addError => _errorMessage.sink.add;
  // getters: Add stream
  Stream<String> get email => _email.stream.transform(validatorEmail);
  Stream<String> get userid => _userid.stream.transform(validatorPassword);
  Stream<String> get password => _password.stream.transform(validatorPassword);
  Stream<String> get errorMessage => _errorMessage.stream;

  Stream<bool> get submitValidForm => Rx.combineLatest3(
        userid,
        password,
        errorMessage,
        (e, p, er) => true,
      );

  late AuthService authInfo;
  // rgister
  dynamic register(BuildContext context) async {
    authInfo = AuthService();

    final res = await authInfo.register(_email.value, _password.value);
    final data = jsonDecode(res) as Map<String, dynamic>;

    if (data['status'] != 200) {
      addError(data['message']);
    } else {
      Navigator.pushNamed(context, '/home');
      return data;
    }
  }

  // login
  login(BuildContext context) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    authInfo = AuthService();
    if (_userid.value.isNotEmpty && _password.value.isNotEmpty) {
      print(_userid.value);
      print(_password.value);

      final response = await authInfo.login(_userid.value, _password.value);

      if (response.statusCode != 200) {
        print(response.statusCode);
        addError('Username atau password salah');
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // print(data);

        SharedPreferences saveLogin = await SharedPreferences.getInstance();
        await saveLogin.setString('dataLogin', jsonEncode(data['data'].first));

        authInfo.fetchCart(context).then((value) {
          profileProvider.setIsLogin(true);
          Navigator.pop(context, true);
          return value;
        });
        // cartProvider.setJumlahItem(fetchJumlahCart['jumlahItem']);
        // cartProvider.setTotalHarga(fetchJumlahCart['totalHarga']);

      }
    }
  }

  // close streams
  dispose() {
    _email.close();
    _password.close();
    _errorMessage.close();
  }
}
