// ignore_for_file: avoid_print, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as Badgenya;
import 'package:mikrotik/providers/cart_provider.dart';
import 'package:mikrotik/screens/home_page_screen.dart';
import 'package:mikrotik/screens/login_screen.dart';
import 'package:mikrotik/screens/shoping_cart_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AppBarShopingCart extends StatelessWidget {
  AppBarShopingCart({Key? key}) : super(key: key);

  final authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(maxWidth: 50),
      // padding: EdgeInsets.zero,
      onPressed: () async {
        if (await authService.cekLogin(context)) {
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const ShopingCartScreen(),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => LoginScreen(),
              )).then((value) async {
            if ((await authService.strDataLogin).toString().isNotEmpty) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  HomePageScreen.routeName, (Route<dynamic> route) => false);

              Navigator.pushNamed(context, ShopingCartScreen.routeName);
            }
          });
        }
      },
      icon: Badgenya.Badge(
        badgeAnimation: Badgenya.BadgeAnimation.fade(
            animationDuration: Duration(milliseconds: 300)),
        badgeContent: Consumer<CartProvider>(builder: (context, cart, child) {
          return Text(
            cart.jumlahItem.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.onError)
                .copyWith(fontSize: 12),
          );
        }),
        position: Badgenya.BadgePosition.topEnd(top: -12, end: -4),
        child: const Icon(Icons.shopping_cart),
        badgeStyle: Badgenya.BadgeStyle(
          badgeColor: Theme.of(context).colorScheme.error,
        ),
      ),
      splashRadius: 24,
    );
  }
}
