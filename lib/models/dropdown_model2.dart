class DropdownModel2 {
  final String id;
  final String name;
  final String total;
  final Map data;

  DropdownModel2(
      {required this.id,
      required this.name,
      required this.total,
      this.data = const {}});

  factory DropdownModel2.fromJson(Map<String, dynamic> json) {
    return DropdownModel2(
      id: json["id"],
      name: json["name"],
      total: json["total"],
      data: json["data"],
    );
  }

  static List<DropdownModel2> fromJsonList(List list) {
    return list.map((item) => DropdownModel2.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#$id $name $total';
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(DropdownModel2? model) {
    return id == model?.id;
  }

  @override
  String toString() => name;
}
