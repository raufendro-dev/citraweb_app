import 'package:flutter/cupertino.dart';

class CartProvider with ChangeNotifier {
  int jumlahItem = 0;
  String totalHarga = '0';
  String ppn = '0';
  String diskon = '0';

  String totalSebelumOngkir = '0';
  List<dynamic> dataBarang = [];

  void setDataBarang(List<dynamic> dataBarang) {
    dataBarang = dataBarang;
    notifyListeners();
  }

  void setJumlahItem(int x) {
    jumlahItem = x;
    notifyListeners();
  }

  void setTotalHarga(String x) {
    totalHarga = x;
    notifyListeners();
  }

  void setPpn(String x) {
    ppn = x;
    notifyListeners();
  }

  void setDiskon(String x) {
    diskon = x;
    notifyListeners();
  }

  void setTotalSebelumOngkir(String x) {
    totalSebelumOngkir = x;
    notifyListeners();
  }

  void plushItem() {
    jumlahItem++;
    notifyListeners();
  }

  void minItem() {
    jumlahItem--;
    notifyListeners();
  }

  void resetCart() {
    jumlahItem = 0;
    totalHarga = '0';
    ppn = '0';
    totalSebelumOngkir = '0';
    notifyListeners();
  }
}
