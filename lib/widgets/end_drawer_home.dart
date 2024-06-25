// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/constant/custom_icons.dart';
import 'package:mikrotik/providers/cart_provider.dart';
import 'package:mikrotik/providers/profile_provider.dart';
import 'package:mikrotik/screens/edit_profile_screen.dart';
import 'package:mikrotik/screens/form_rma.dart';
import 'package:mikrotik/screens/home_page_screen.dart';
import 'package:mikrotik/screens/kontak_screen.dart';
import 'package:mikrotik/screens/login_screen.dart';
import 'package:mikrotik/screens/page_screen.dart';
import 'package:mikrotik/screens/riwayat_pesanan_screen.dart';
import 'package:mikrotik/screens/riwayat_rma_screen.dart';
import 'package:mikrotik/screens/riwayat_training_screen.dart';
import 'package:mikrotik/services/auth_service.dart';
import 'package:mikrotik/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/cekgaransi_screen.dart';
import '../main.dart' show slideDirection;

class EndDrawerHome extends StatefulWidget {
  const EndDrawerHome({
    Key? key,
  }) : super(key: key);

  @override
  State<EndDrawerHome> createState() => _EndDrawerHomeState();
}

class _EndDrawerHomeState extends State<EndDrawerHome> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: true);

    if (!profileProvider.isLogin ||
        (profileProvider.isLogin && profileProvider.profile.isEmpty)) {
      // const EditProfilScreen().createState().fetchProfile().then((value) {
      //   profileProvider.setProfile(value);
      //   setState(() {});
      // });
      AuthService().cekLogin(context).then((value) {
        if (value) {
          const EditProfilScreen().createState().fetchProfile().then((value) {
            profileProvider.setProfile(value);
            profileProvider.setIsLogin(true);
            setState(() {});
          });
        }
      });
    }

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            height: 160,
            child: profileProvider.isLogin
                ? DrawerHeader(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).viewPadding.top,
                      bottom: 12,
                      left: 12,
                      right: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: ListTile(
                      // dense: true,
                      contentPadding: EdgeInsets.zero,
                      tileColor: Theme.of(context).colorScheme.primary,
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.background,
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.person,
                            size: 42,
                          ),
                        ),
                      ),
                      title: profileProvider.profile.isEmpty
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child:
                                  const ShimmerWidget.rectangular(height: 16))
                          : Text(
                              profileProvider.profile['nama'],
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.background),
                            ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          profileProvider.profile.isEmpty
                              ? Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: const ShimmerWidget.rectangular(
                                    height: 10,
                                    width: 120,
                                  ))
                              : Text(
                                  profileProvider.profile['email'],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background),
                                ),
                          profileProvider.profile.isEmpty
                              ? const ShimmerWidget.rectangular(
                                  height: 10,
                                  width: 100,
                                )
                              : Text(
                                  profileProvider.profile['selular'],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background),
                                ),
                        ],
                      ),
                      trailing: Container(
                        // color: Colors.white,
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        child: IconButton(
                          splashRadius: 24,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilScreen(
                                    // profileObj: profil,
                                    ),
                              ),
                            ).then(
                              (value) {
                                if (value) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    HomePageScreen.routeName,
                                    (Route<dynamic> route) => false,
                                    arguments: 4,
                                  );
                                }
                              },
                            );
                          },
                          icon: const Icon(Icons.settings),
                          alignment: Alignment.center,
                          padding: EdgeInsets.zero,
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ),
                    ),
                  )
                : FutureBuilder<bool>(
                    future: AuthService().cekLogin(context),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && !snapshot.data!) {
                        return Center(
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                                primary:
                                    Theme.of(context).colorScheme.background,
                              ),
                              onPressed: () {
                                print('log');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        LoginScreen(),
                                  ),
                                ).then((isLogin) async {
                                  if (isLogin) {
                                    profileProvider.setIsLogin(true);

                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      HomePageScreen.routeName,
                                      (Route<dynamic> route) => false,
                                    );
                                  }
                                });
                              },
                              child: const Text('Login')),
                        );
                      }
                      return Center(
                          child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.background,
                      ));
                    }),
          ),
          Expanded(
            child: Ink(
              color: Theme.of(context).colorScheme.background,
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Text(
                      'Aktivitas Saya',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    minLeadingWidth: 0,
                    leading: Container(
                      width: 32,
                      alignment: Alignment.centerLeft,
                      // margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.event_note,
                        color: Colors.grey.shade800,
                        size: 26,
                      ),
                    ),
                    horizontalTitleGap: 0,
                    title: Text(
                      'Riwayat Pesanan',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    dense: true,
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    onTap: () {
                      if (profileProvider.isLogin) {
                        // Navigator.of(context).pop();
                        Navigator.of(context).push(_createRoute(
                            const RiwayatPesananScreen(),
                            slideDirection.toLeft));
                      }
                    },
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    minLeadingWidth: 0,
                    leading: Container(
                      width: 32,
                      padding: const EdgeInsets.only(left: 2),
                      alignment: Alignment.centerLeft,
                      // margin: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        CustomIcons.training,
                        color: Colors.grey.shade800,
                        size: 24,
                      ),
                    ),
                    horizontalTitleGap: 0,
                    title: Text(
                      'Riwayat Training',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    dense: true,
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    onTap: () {
                      if (profileProvider.isLogin) {
                        // Navigator.pop(context);
                        Navigator.of(context).push(_createRoute(
                            const RiwayatTrainingScreen(),
                            slideDirection.toLeft));
                      }
                    },
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    minLeadingWidth: 0,
                    leading: Container(
                      width: 32,
                      padding: const EdgeInsets.only(left: 2),
                      alignment: Alignment.centerLeft,
                      // margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        FontAwesomeIcons.tools,
                        color: Colors.grey.shade800,
                        size: 20,
                      ),
                    ),
                    horizontalTitleGap: 0,
                    title: Text(
                      'Riwayat RMA',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    dense: true,
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    onTap: () {
                      if (profileProvider.isLogin) {
                        // Navigator.pop(context);
                        Navigator.of(context).push(_createRoute(
                            const RiwayatRmaScreen(), slideDirection.toLeft));
                      }
                    },
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    minLeadingWidth: 0,
                    leading: Container(
                      width: 32,
                      padding: const EdgeInsets.only(left: 2),
                      alignment: Alignment.centerLeft,
                      // margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        FontAwesomeIcons.wpforms,
                        color: Colors.grey.shade800,
                        size: 22,
                      ),
                    ),
                    horizontalTitleGap: 0,
                    title: Text(
                      'Pengajuan RMA',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    dense: true,
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    onTap: () {
                      if (profileProvider.isLogin) {
                        // Navigator.pop(context);
                        Navigator.of(context)
                            .push(_createRoute(
                                const FormRma(), slideDirection.toLeft))
                            .then((value) {
                          if (value ?? false) {
                            Navigator.pop(context);
                            Navigator.of(context).push(_createRoute(
                                const RiwayatRmaScreen(),
                                slideDirection.toLeft));
                          }
                        });
                      }
                    },
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    minLeadingWidth: 0,
                    leading: Container(
                      width: 32,
                      // padding: const EdgeInsets.only(left: 2),
                      alignment: Alignment.centerLeft,
                      // margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.verified_user_outlined,
                        color: Colors.grey.shade800,
                        size: 24,
                      ),
                    ),
                    horizontalTitleGap: 0,
                    title: Text(
                      'Cek Garansiiiiii',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    dense: true,
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    onTap: () {
                      // Navigator.pop(context);
                      // launch(Config.baseUrlApi + 'warranty_check/');
                      Navigator.of(context).push(_createRoute(
                          const CekgaransiScreen(), slideDirection.toLeft));
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Text(
                      'Tentang',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    minLeadingWidth: 0,
                    leading: Container(
                      width: 32,
                      // padding: const EdgeInsets.only(left: 2),
                      alignment: Alignment.centerLeft,
                      // margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        CustomIcons.fivestars,
                        color: Colors.grey.shade800,
                        size: 24,
                      ),
                    ),
                    horizontalTitleGap: 0,
                    title: Text(
                      'Tentang Kami',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    dense: true,
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    onTap: () {
                      // Navigator.pop(context);

                      Navigator.of(context).push(_createRoute(
                          const PageScreen(
                            title: '',
                            idPage: 1,
                          ),
                          slideDirection.toLeft));
                    },
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    minLeadingWidth: 0,
                    leading: Container(
                      width: 32,
                      // padding: const EdgeInsets.only(left: 2),
                      alignment: Alignment.centerLeft,
                      // margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.assignment_outlined,
                        color: Colors.grey.shade800,
                        size: 24,
                      ),
                    ),
                    horizontalTitleGap: 0,
                    title: Text(
                      'Aturan',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    dense: true,
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    onTap: () {
                      // Navigator.pop(context);
                      Navigator.of(context).push(_createRoute(
                          const PageScreen(
                            title: '',
                            idPage: 4,
                          ),
                          slideDirection.toLeft));
                    },
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    minLeadingWidth: 0,
                    leading: Container(
                      width: 32,
                      // padding: const EdgeInsets.only(left: 2),
                      alignment: Alignment.centerLeft,
                      // margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.help_outline_outlined,
                        color: Colors.grey.shade800,
                        size: 24,
                      ),
                    ),
                    horizontalTitleGap: 0,
                    title: Text(
                      'Pusat Bantuan',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    dense: true,
                    minVerticalPadding: 0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    onTap: () {
                      // Navigator.pop(context);
                      Navigator.of(context).push(_createRoute(
                          const KontakScreen(), slideDirection.toLeft));
                    },
                  ),
                  if (profileProvider.isLogin)
                    const Divider(
                      indent: 14,
                      endIndent: 14,
                    ),
                  if (profileProvider.isLogin)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: OutlinedButton.icon(
                          onPressed: () async {
                            await AuthService().logout().then((isLogout) {
                              if (isLogout) {
                                cartProvider.resetCart();
                                profileProvider.setIsLogin(false);

                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  HomePageScreen.routeName,
                                  (Route<dynamic> route) => false,
                                );
                              }
                            });
                          },
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                          icon: const Icon(Icons.logout),
                          label: const Text('Keluar')),
                    ),
                  // ListTile(
                  //   tileColor: Colors.white,
                  //   minLeadingWidth: 0,
                  //   leading: Container(
                  //     width: 32,
                  //     // padding: const EdgeInsets.only(left: 2),
                  //     alignment: Alignment.centerLeft,
                  //     // margin: const EdgeInsets.only(right: 8),
                  //     child: Icon(
                  //       Icons.power_settings_new,
                  //       color: Colors.grey.shade800,
                  //       size: 24,
                  //     ),
                  //   ),
                  //   horizontalTitleGap: 0,
                  //   title: Text(
                  //     'Keluar',
                  //     style: TextStyle(
                  //       color: Colors.grey.shade800,
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //   ),
                  //   dense: true,
                  //   minVerticalPadding: 0,
                  //   contentPadding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 0,
                  //   ),
                  //   onTap: () {
                  //     // Navigator.pop(context);
                  //     Navigator.of(context).push(_createRoute(
                  //         const KontakScreen(), slideDirection.toLeft));
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute(page, slideDirection direction) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        const end = Offset.zero;
        if (direction == slideDirection.toLeft) {
          begin = const Offset(1.0, 0.0);
        } else {
          begin = const Offset(0.0, 1.0);
        }
        const curve = Curves.linear;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return Stack(
          children: [
            SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          ],
        );
      },
    );
  }
}
