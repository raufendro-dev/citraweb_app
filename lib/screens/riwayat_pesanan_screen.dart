import 'package:flutter/material.dart';
import 'package:mikrotik/widgets/order_tab_content.dart';

class RiwayatPesananScreen extends StatelessWidget {
  const RiwayatPesananScreen({Key? key}) : super(key: key);

  static const List<Map> _tabOrders = [
    {'id_status': -1},
    {'id_status': 2},
    {'id_status': 3},
    {'id_status': 4},
    {'id_status': 5},
    {'id_status': 6},
    {'id_status': 7},
    {'id_status': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabOrders.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Pesanan'),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primaryVariant,
            labelStyle: Theme.of(context).textTheme.caption,
            isScrollable: true,
            tabs: [
              const Tab(child: Text('Semua')),
              Tab(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Menunggu'),
                    Text('Approval'),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Menunggu'),
                    Text('Pembayaran'),
                  ],
                ),
              ),
              const Tab(child: Text('Pending')),
              const Tab(child: Text('Dibayar')),
              const Tab(child: Text('Dikemas')),
              const Tab(child: Text('Dikirim')),
              const Tab(child: Text('Batal')),
            ],
          ),
        ),
        body: Center(
          child: TabBarView(
            children: [
              ..._tabOrders
                  .map((e) => OrderTabContent(idStatus: e['id_status'])),
            ],
          ),
        ),
      ),
    );
  }
}
