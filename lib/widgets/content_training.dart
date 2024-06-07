// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mikrotik/screens/detail_training_screen.dart';
// import 'package:mikrotik/screens/detail_artikel_screen.dart';
import 'dart:convert';

import '../constant/config.dart';

class ContentTraining extends StatefulWidget {
  const ContentTraining({Key? key}) : super(key: key);

  @override
  State<ContentTraining> createState() => _ContentTrainingState();
}

class _ContentTrainingState extends State<ContentTraining>
    with
        AutomaticKeepAliveClientMixin<ContentTraining>,
        TickerProviderStateMixin {
  List<String> listKategori = ['regular', 're-certification'];
  final int _selectedTab = 0;

  final PageController _pageViewController = PageController(initialPage: 0);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: listKategori.length);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build training');
    // return BuilderTraining(listTraining: listTraining);

    return DefaultTabController(
      length: 2,
      initialIndex: _selectedTab,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                print('tab $index');
                _pageViewController.animateToPage(index,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.linear);
              },
              padding: EdgeInsets.zero,
              indicatorColor: Theme.of(context).colorScheme.primaryVariant,
              labelColor: Theme.of(context).colorScheme.primaryVariant,
              unselectedLabelColor: Colors.white70,
              tabs: [
                ...listKategori.map(
                  (e) => Tab(
                    text: e.toUpperCase(),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: PageView(
              onPageChanged: (index) async {
                print('slide tab $index');

                if (!_tabController.indexIsChanging) {
                  print('ok');
                  _tabController.animateTo(index,
                      duration:
                          const Duration(milliseconds: 100)); // Switch tabs
                }
              },
              controller: _pageViewController,
              children: listKategori
                  .map(
                    (e) => BuilderTraining(
                        key: PageStorageKey('listTraining$e'), type: e),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BuilderTraining extends StatefulWidget {
  const BuilderTraining({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  State<BuilderTraining> createState() => _BuilderTrainingState();
}

class _BuilderTrainingState extends State<BuilderTraining>
    with AutomaticKeepAliveClientMixin<BuilderTraining> {
  List<Map<String, dynamic>> listTraining = [];
  final _listviewcontroller = ScrollController();
  Future<List<Map<String, dynamic>>> fetchTraining(
      {String type = 'regular'}) async {
    final List<Map<String, dynamic>> listTraining = [];

    final responseTraining = await http.get(Uri.parse(Config.baseUrlApi +
        'app-api/training/$type/?key=0cc7da679bea04fea453c8062e06514d'));
    if (responseTraining.statusCode == 200) {
      print('fetchTraining');
      final Map training = jsonDecode(responseTraining.body);
      if (training['data'].isNotEmpty) {
        for (var infoTraining in training['data']) {
          listTraining.add(infoTraining);
        }
      }
    } else {
      print('Failed to load Produk Baru');
    }
    return listTraining;
  }

  @override
  void initState() {
    super.initState();

    fetchTraining(type: widget.type).then((value) {
      setState(() {
        listTraining = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build tab ${widget.type}');
    print(listTraining);
    return FutureBuilder<List<Map<String, dynamic>>>(
        // future: fetchTraining(),
        initialData: listTraining,
        builder: (context, snapshot) {
          if (listTraining.isNotEmpty) {
            return ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                      height: 0,
                    ),
                controller: _listviewcontroller,
                itemCount: listTraining.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: Theme.of(context).colorScheme.background,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailTrainingScreen(
                                    id: int.parse(listTraining[index]['id']),
                                    // initialData: listTraining[index],
                                  )));
                    },
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(listTraining[index]['nama']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listTraining[index]['kapasitas'] + ' orang'),
                        Text(listTraining[index]['kota']),
                        ...listTraining[index]['tanggal'].split(',').map(
                            (value) => Text(
                                value[0] == ' ' ? value.substring(1) : value)),
                      ],
                    ),
                  );
                });
          }
          // return const Center(child: CircularProgressIndicator());
          return const Center(child: Text("Tidak ada training"));
        });
  }

  @override
  bool get wantKeepAlive => true;
}
