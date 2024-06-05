// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mikrotik/providers/cart_provider.dart';
import 'package:mikrotik/providers/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../constant/config.dart';

class AuthService {
  final baseUrl = Config.baseUrlApi;

  Future<SharedPreferences> getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<String?> get strDataLogin async {
    return await getPref().then((value) => value.getString('dataLogin') ?? '');
    // return localData.then((value) => value.getString('dataLogin') ?? '');
  }

  get idUser async {
    return jsonDecode((await strDataLogin).toString())['MKid'];
  }

  get sessId async {
    return jsonDecode((await strDataLogin).toString())['sess_id'];
  }

  static Future<String> getIPAddress() async {
    try {
      final url = Uri.parse('https://api.ipify.org');
      final response = await http.get(url);

      return response.statusCode == 200 ? response.body.toString() : '';
    } catch (e) {
      return '';
    }
  }

  Future<dynamic> register(String email, String password) async {
    try {
      var res = await http.post(Uri.parse('$baseUrl/auth/register'), body: {
        'email': email,
        'password': password,
      });

      return res.body;
    } finally {
      // done you can do something here
    }
  }

  Future<http.Response> login(String userid, String password) async {
    String ip = await getIPAddress().then((value) => value);
    try {
      var response = await http.post(Uri.parse('${baseUrl}app-api/login/'),
          body: jsonEncode({
            'key': '0cc7da679bea04fea453c8062e06514d',
            'userid': userid,
            'password': password,
            'ip': ip,
          }));

      return response;
    } finally {
      // you can do somethig here
    }
  }

  Future<bool> cekLogin(BuildContext context) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    String data = (await strDataLogin).toString();
    if (data.isNotEmpty) {
      Map<String, dynamic> dataLogin = jsonDecode(data);
      print(jsonEncode({
        'key': '0cc7da679bea04fea453c8062e06514d',
        'iduser': dataLogin['MKid'],
        'sess_id': dataLogin['sess_id'],
      }));
      try {
        var response =
            await http.post(Uri.parse('${baseUrl}app-api/login/ceklogin/'),
                body: jsonEncode({
                  'key': '0cc7da679bea04fea453c8062e06514d',
                  'iduser': dataLogin['MKid'],
                  'sess_id': dataLogin['sess_id'],
                }));

        if (response.statusCode != 200) {
          await getPref().then((value) => value.setString('dataLogin', ''));
          profileProvider.setIsLogin(true);
          return false;
        }
        return true;
      } finally {
        // you can do somethig here

      }
    }
    return false;
  }

  Future<Map<String, dynamic>> fetchCart(BuildContext context) async {
    final responseCart = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/keranjang/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        (await strDataLogin
            .then((value) => jsonDecode(value.toString())['MKid'])) +
        '&sess_id=' +
        (await strDataLogin
            .then((value) => jsonDecode(value.toString())['sess_id'])) +
        ''));
    if (responseCart.statusCode == 200) {
      print('fetchisicart');
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      final Map cart = jsonDecode(responseCart.body);
      if (cart['data'].first['ada_kerangjang']) {
        int jml = 0;
        for (var cartItem in cart['data'].first['data_barang']) {
          jml += int.parse(cartItem['jum_barang']);
        }
        cartProvider.setDataBarang(cart['data'].first['data_barang']);
        cartProvider.setJumlahItem(jml);
        cartProvider.setTotalHarga(cart['data'].first['total_harga_barang']);
        cartProvider.setPpn(cart['data'].first['ppn_rp']);
        cartProvider
            .setTotalSebelumOngkir(cart['data'].first['total_sebelum_ongkir']);
        return {
          'jumlahItem': jml,
          'totalHarga': cart['data'].first['total_harga_barang'],
          'ppn': cart['data'].first['ppn_rp'],
          'totalSebelumOngkir': cart['data'].first['total_sebelum_ongkir'],
        };
      } else {
        cartProvider.resetCart();
      }
    } else {
      print('Failed to load cart');
    }

    return {'jumlahItem': 0, 'totalHarga': 0};
  }

  Future<bool> logout() async {
    return await getPref().then((value) => value.setString('dataLogin', ''));
  }
}
