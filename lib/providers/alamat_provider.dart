import 'package:flutter/material.dart';

class alamatProvider with ChangeNotifier {
  // Properties
  int _isDiambil = 0; // Initial value
  int _MKidTujuan = 0; // Initial value

  // Getters
  int get isDiambil => _isDiambil;
  int get MKidTujuan => _MKidTujuan;

  // Methods to update state
  void updateIsDiambil(int newValue) {
    _isDiambil = newValue;
    notifyListeners();
  }

  void updateMKidTujuan(int newValue) {
    print(newValue);
    _MKidTujuan = newValue;
    notifyListeners();
  }

  // Method to get the JSON structure
  Map<String, dynamic> toJson() {
    return {
      "isDiambil": _isDiambil,
      "MKid_tujuan": _MKidTujuan,
    };
  }
}
