// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mikrotik/providers/cart_provider.dart';
import 'package:mikrotik/providers/alamat_provider.dart';
import 'package:mikrotik/providers/profile_provider.dart';
import 'package:mikrotik/screens/detail_artikel_screen.dart';
import 'package:mikrotik/screens/detail_training_screen.dart';
import 'package:mikrotik/screens/shoping_cart_screen.dart';
import 'package:provider/provider.dart';

import 'screens/home_page_screen.dart';
import 'screens/detail_product_screen.dart';
import 'providers/login_provider.dart';

void main() {
  runApp(const MyApp());
}

enum slideDirection {
  toTop,
  toLeft,
}
// function to make fibonacci

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print('build main');
    return LoginProvider(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => CartProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => ProfileProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => alamatProvider(),
          ),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mikrotik',
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.grey[100],
              // This is the theme of your application.
              primarySwatch: Colors.blue,
              primaryColor: const Color.fromRGBO(77, 22, 131, 1),
              colorScheme: const ColorScheme(
                  primary: Color.fromRGBO(77, 22, 131, 1),
                  primaryVariant: Color(0xffd67628),
                  secondary: Color(0xffe6232a),
                  secondaryVariant: Color(0xffc32d30),
                  surface: Colors.white,
                  background: Colors.white,
                  error: Color(0xffe6232a),
                  onPrimary: Colors.white,
                  onSecondary: Colors.white,
                  onSurface: Colors.black,
                  onBackground: Colors.black,
                  onError: Colors.white,
                  brightness: Brightness.light),
              textTheme: const TextTheme(
                bodyText1: TextStyle(fontSize: 18),
                bodyText2: TextStyle(fontSize: 14),
              ),
              // colorScheme: ColorScheme(primary: primary, primaryVariant: primaryVariant, secondary: secondary, secondaryVariant: secondaryVariant, surface: surface, background: background, error: error, onPrimary: onPrimary, onSecondary: onSecondary, onSurface: onSurface, onBackground: onBackground, onError: onError, brightness: brightness)
            ),
            home: const HomePageScreen(title: 'Citraweb', indexPindah: 0),
            routes: {
              HomePageScreen.routeName: (ctx) =>
                  const HomePageScreen(title: 'Citraweb', indexPindah: 0),
              DetailProductScreen.routeName: (ctx) => const DetailProductScreen(
                    productId: 0,
                  ),
              ShopingCartScreen.routeName: (ctx) => const ShopingCartScreen(),
              DetailArtikelScreen.routeName: (ctx) => const DetailArtikelScreen(
                    id: 0,
                  ),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case DetailTrainingScreen.routeName:
                  final args = settings.arguments.toString();
                  return MaterialPageRoute(
                    builder: (context) =>
                        DetailTrainingScreen(id: int.parse(args)),
                  );
                default:
              }
            }),
      ),
    );
  }
}
