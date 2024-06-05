class Config {
  static const baseUrlApi = 'https://mkt.citraweb.co.id/';

  static const List<Map<String, dynamic>> listCustomCategory = [
    {
      "api":
          "app-api/depan/index_produk/?key=0cc7da679bea04fea453c8062e06514d&indexproduk=router_indoor_soho",
      "color": "693476",
    },
    {
      "api":
          "app-api/depan/index_produk/?key=0cc7da679bea04fea453c8062e06514d&indexproduk=router_indoor_access_point",
      "color": "6C4DA5",
    },
    {
      "api":
          "app-api/depan/index_produk/?key=0cc7da679bea04fea453c8062e06514d&indexproduk=rackmount_router",
      "color": "6656FF",
    },
    {
      "api":
          "app-api/depan/index_produk/?key=0cc7da679bea04fea453c8062e06514d&indexproduk=wireless_outdoor",
      "color": "A54D59",
    },
    {
      "api":
          "app-api/depan/index_produk/?key=0cc7da679bea04fea453c8062e06514d&indexproduk=switch",
      "color": "383EB4",
    },
    {
      "api":
          "app-api/depan/index_produk/?key=0cc7da679bea04fea453c8062e06514d&indexproduk=mikrobits_router",
      "color": "FF5656",
    },
  ];

  mktToCst(String x) {
    return x.replaceAll('mkt.citraweb.co.id', 'citraweb.com');
  }
}
