import 'package:flutter/cupertino.dart';

class ProfileProvider with ChangeNotifier {
  bool isLogin = false;
  Map<String, dynamic> profile = {};

  void setProfile(profilenya) {
    profile = profilenya;
  }

  void setIsLogin(bool x) {
    isLogin = x;
  }
}
