// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mikrotik/constant/config.dart';
import 'package:mikrotik/services/auth_service.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({Key? key, this.profileObj = const {}})
      : super(key: key);
  final Map<String, dynamic> profileObj;

  @override
  _EditProfilScreenState createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final authService = AuthService();
  final passlama = TextEditingController();
  final FocusNode passlamafocus = FocusNode();
  final passbaru = TextEditingController();
  final passkonf = TextEditingController();
  late final email = TextEditingController(text: widget.profileObj['email']);
  final FocusNode emailfocus = FocusNode();
  String cekPasswordText = '';
  String cekEmailText = '';

  bool edited = false;

  late Map<String, dynamic> profileObj = widget.profileObj;

  Future<Map<String, dynamic>> fetchProfile() async {
    Map<String, dynamic> profileObj = {};
    var dataLogin = jsonDecode((await authService.strDataLogin).toString());

    final responseProfile = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/profil/?key=0cc7da679bea04fea453c8062e06514d&iduser=' +
        dataLogin['MKid'] +
        '&sess_id=' +
        dataLogin['sess_id']));
    if (responseProfile.statusCode == 200) {
      print('fetchProfile');
      final Map profil = jsonDecode(responseProfile.body);
      if (profil['data'].isNotEmpty) {
        // for (var infoProfile in profil['data']) {
        //   // profileObj.add(infoProfile);

        // }
        profileObj = profil['data'].first;
      }
    } else {
      print('Failed to load Profile');
    }
    return profileObj;
  }

  Future<Map<String, dynamic>> gantiEmail() async {
    var dataLogin = jsonDecode((await authService.strDataLogin).toString());
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/profil/ubahemail/'),
      body: jsonEncode({
        "key": "0cc7da679bea04fea453c8062e06514d",
        "iduser": dataLogin['MKid'],
        "sess_id": dataLogin['sess_id'],
        "email": email.text,
      }),
    );
    print(res.body);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'].first;
    }
    return {
      "diganti": false,
      "msg": "Terjadi kesalahan saat penggantian password"
    };
  }

  Future<Map<String, dynamic>> gantiPassword() async {
    var dataLogin = jsonDecode((await authService.strDataLogin).toString());
    var res = await http.post(
      Uri.parse(Config.baseUrlApi + 'app-api/profil/ubahpassword/'),
      body: jsonEncode({
        "key": "0cc7da679bea04fea453c8062e06514d",
        "iduser": dataLogin['MKid'],
        "sess_id": dataLogin['sess_id'],
        "email": profileObj['email'],
        "password_lama": passlama.text,
        "password_baru": passbaru.text,
        "password_baru_ulangi": passkonf.text,
      }),
    );
    print(res.body);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'].first;
    }
    return {
      "diganti": false,
      "msg": "Terjadi kesalahan saat penggantian password"
    };
  }

  @override
  void initState() {
    super.initState();
    if (profileObj.isEmpty) {
      fetchProfile().then((value) {
        setState(() {
          profileObj = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Profil'),
      ),
      body: profileObj.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : WillPopScope(
              onWillPop: () async {
                Navigator.pop(context, edited);
                return false;
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        // padding: const EdgeInsets.all(12),
                        color: Theme.of(context).colorScheme.background,
                        width: double.infinity,
                        // margin: const EdgeInsets.only(bottom: 16),
                        child: Icon(
                          Icons.person,
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                          top:
                              BorderSide(width: 1, color: Colors.grey.shade300),
                          bottom:
                              BorderSide(width: 1, color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Nama'),
                          Text(profileObj['nama']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('User Id'),
                          Text(profileObj['userid']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Email'),
                          Row(
                            children: [
                              Text(profileObj['email']),
                              SizedBox(
                                height: 40,
                                child: Material(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0)),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    splashRadius: 16,
                                    onPressed: () {
                                      final _keyEmail = GlobalKey<FormState>();
                                      showModalBottomSheet<void>(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(12)),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                                // color: Colors.grey,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Ubah Email',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6!
                                                      .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .background),
                                                ),
                                              ),
                                              Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .background,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12),
                                                child: Form(
                                                  key: _keyEmail,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      const SizedBox(
                                                          height: 30),
                                                      TextFormField(
                                                        validator: (value) {
                                                          if (value!.isEmpty ||
                                                              !value.contains(
                                                                  '@')) {
                                                            return 'Silahkan masukan alamat email';
                                                          }
                                                          return null;
                                                        },
                                                        focusNode: emailfocus,
                                                        controller: email,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Email baru',
                                                          errorText: cekEmailText
                                                                  .isNotEmpty
                                                              ? cekEmailText
                                                              : null,
                                                          errorMaxLines: 3,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          if (_keyEmail
                                                              .currentState!
                                                              .validate()) {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            gantiEmail()
                                                                .then((value) {
                                                              if (value[
                                                                  'diganti']) {
                                                                fetchProfile()
                                                                    .then(
                                                                        (value) {
                                                                  setState(() {
                                                                    print(
                                                                        value);
                                                                    edited =
                                                                        true;
                                                                    profileObj =
                                                                        value;
                                                                  });
                                                                });
                                                                cekEmailText =
                                                                    '';
                                                                Navigator.pop(
                                                                    context);
                                                              } else {
                                                                setState(() {
                                                                  cekEmailText =
                                                                      value[
                                                                          'msg'];
                                                                  emailfocus
                                                                      .requestFocus();
                                                                  print(
                                                                      cekEmailText);
                                                                });
                                                              }
                                                            });
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Simpan'),
                                                      ),
                                                      const SizedBox(
                                                          height: 40),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding:
                                                      MediaQuery.of(context)
                                                          .viewInsets),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Selular'),
                          Text(profileObj['selular']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Perusahaan'),
                          Text(profileObj['perusahaan']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jenis'),
                          Text(profileObj['jenis_perusahaan']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jabatan'),
                          Text(profileObj['jabatan']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Telp'),
                          Text(profileObj['telp']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fax'),
                          Text(profileObj['fax']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Alamat'),
                          Text(profileObj['alamat']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kota'),
                          Text(profileObj['nama_kota']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kode Pos'),
                          Text(profileObj['kodepos']),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Situs'),
                          Text(profileObj['url']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        border: Border(
                          top:
                              BorderSide(width: 1, color: Colors.grey.shade300),
                          bottom:
                              BorderSide(width: 1, color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ubah Password'),
                          Material(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                            child: IconButton(
                              onPressed: () {
                                final _keyForm = GlobalKey<FormState>();
                                showModalBottomSheet<void>(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          // color: Colors.grey,
                                          child: Text(
                                            'Ubah Password',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background),
                                          ),
                                        ),
                                        Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Form(
                                            key: _keyForm,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                const SizedBox(height: 30),
                                                TextFormField(
                                                  obscureText: true,
                                                  enableSuggestions: false,
                                                  autocorrect: false,
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: 'Password Lama',
                                                    errorText: cekPasswordText
                                                            .isNotEmpty
                                                        ? cekPasswordText
                                                        : null,
                                                    errorMaxLines: 3,
                                                  ),
                                                  controller: passlama,
                                                  focusNode: passlamafocus,
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Password kosong';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 12),
                                                TextFormField(
                                                  textAlign: TextAlign.center,
                                                  decoration:
                                                      const InputDecoration(
                                                          isDense: true,
                                                          hintText:
                                                              'Password Baru'),
                                                  controller: passbaru,
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Password baru kosong';
                                                    } else if (value.length <
                                                        6) {
                                                      return 'Minimal 6 karakter';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 12),
                                                TextFormField(
                                                  textAlign: TextAlign.center,
                                                  decoration: const InputDecoration(
                                                      isDense: true,
                                                      hintText:
                                                          'Konfirmasi Password Baru'),
                                                  controller: passkonf,
                                                  validator: (value) {
                                                    if (value! !=
                                                        passbaru.text) {
                                                      return 'Konfirmasi password salah';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (_keyForm.currentState!
                                                        .validate()) {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      gantiPassword()
                                                          .then((value) {
                                                        if (value['diganti']) {
                                                          setState(() {
                                                            edited = true;
                                                            passlama.text = '';
                                                            passbaru.text = '';
                                                            passkonf.text = '';
                                                            cekPasswordText =
                                                                '';
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          setState(() {
                                                            cekPasswordText =
                                                                value['msg'];
                                                            passlamafocus
                                                                .requestFocus();
                                                            print(
                                                                cekPasswordText);
                                                          });
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: const Text('Simpan'),
                                                ),
                                                const SizedBox(height: 40),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding: MediaQuery.of(context)
                                                .viewInsets),
                                      ],
                                    );
                                  },
                                ).whenComplete(() {
                                  setState(() {
                                    passlama.text = '';
                                    passbaru.text = '';
                                    passkonf.text = '';
                                    cekPasswordText = '';
                                  });
                                });
                              },
                              icon: const Icon(Icons.keyboard_arrow_down),
                              // splashColor: Colors.red,
                              splashRadius: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
