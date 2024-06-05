class DropdownModel {
  final String id;
  final String name;
  final Map data;

  DropdownModel({required this.id, required this.name, this.data = const {}});

  factory DropdownModel.fromJson(Map<String, dynamic> json) {
    return DropdownModel(
      id: json["id"],
      name: json["name"],
      data: json["data"],
    );
  }

  static List<DropdownModel> fromJsonList(List list) {
    return list.map((item) => DropdownModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#$id $name';
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(DropdownModel? model) {
    return id == model?.id;
  }

  @override
  String toString() => name;
}
