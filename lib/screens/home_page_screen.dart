// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:mikrotik/providers/cart_provider.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:mikrotik/widgets/app_bar_home.dart';
// import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mikrotik/widgets/content_artikel.dart';
import 'package:mikrotik/widgets/content_profile.dart';
import 'package:mikrotik/widgets/content_training.dart';
import 'package:mikrotik/widgets/end_drawer_home.dart';
import '../widgets/content_beranda.dart';
import '../widgets/content_produk.dart';
import '../constant/custom_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen(
      {Key? key, required this.title, required this.indexPindah})
      : super(key: key);
  static const routeName = 'HomePageScreen';

  final String title;
  final int indexPindah;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>
    with AutomaticKeepAliveClientMixin<HomePageScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  late final PageController _pageController;

  static const List<Widget> pageOption = [
    ContentBeranda(),
    ContentTraining(),
    ContentProduk(),
    ContentArtikel(),
    ContentProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.indexPindah;

    _pageController = PageController(initialPage: _selectedIndex);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final args = ModalRoute.of(context)!.settings.arguments.toString();
      print('args=' + args);
      if (args != 'null' && args.isNotEmpty) {
        setState(() {
          _selectedIndex = int.parse(args);
          _pageController.jumpToPage(int.parse(args));
        });
      }
      // final cartProvider = Provider.of<CartProvider>(context, listen: false);
      AuthService().cekLogin(context).then((value) async {
        if (value) {
          AuthService().fetchCart(context);
          // await AuthService().fetchCart().then((value) {
          //   cartProvider.setJumlahItem(value['jumlahItem']);
          //   cartProvider.setTotalHarga(value['totalHarga']);
          // });
        }
      });
    });
    // if (widget.indexPindah != 0) {
    //   setState(() {
    //     _selectedIndex = widget.indexPindah;
    //     _pageController.animateToPage(
    //       widget.indexPindah,
    //       duration: Duration(milliseconds: 500),
    //       curve: Curves.ease,
    //     );
    //   });
    // }
  }

  DateTime currentBackPressTime =
      DateTime.now().subtract(const Duration(seconds: 2));

  Future<bool> onWillPop() {
    if (_scaffoldKey.currentState!.isEndDrawerOpen) {
      return Future.value(true);
    }
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      // Fluttertoast.showToast(msg: 'exit_warning');
      Fluttertoast.showToast(
        msg: "Tekan sekali lagi untuk keluar",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build home screen');
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // Status bar color
      statusBarColor: Colors.transparent,

      // Status bar brightness (optional)
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)

      // systemNavigationBarContrastEnforced: true,
      // systemNavigationBarDividerColor: Theme.of(context).colorScheme.primary,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      // systemStatusBarContrastEnforced: true,
    ));

    return Scaffold(
      key: _scaffoldKey,
      // extendBodyBehindAppBar: true,
      appBar: const AppBarHome(),
      endDrawer: const EndDrawerHome(),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Listener(
          onPointerDown: (_) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusScope.of(context).unfocus();
            }
          },
          child: PageView(
            // key: const PageStorageKey('home'),
            controller: _pageController,
            //The following parameter is just to prevent
            //the user from swiping to the next page.
            physics: const NeverScrollableScrollPhysics(),
            children: pageOption,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: FaIcon(FontAwesomeIcons.whatsapp),
        label: Text("Tanya Kami"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          String url = "https://wa.me/+628112039555/?text=%20Halo%20Citraweb%2C%0A%20Nama%20%3A%20%0A%20Perusahaan%20%3A%20%0A%20Pertanyaan%20%3A%20";
          launch(url);
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black12,
              width: 0.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(CustomIcons.training),
              label: 'Training',
            ),
            BottomNavigationBarItem(
              icon: Icon(CustomIcons.category),
              label: 'Produk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'Artikel',
            ),
            BottomNavigationBarItem(
              icon: Icon(CustomIcons.user),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Theme.of(context).colorScheme.primary,
          selectedItemColor: Theme.of(context).colorScheme.primaryVariant,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
