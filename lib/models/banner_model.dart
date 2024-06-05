class BannerModel {
  final String link;
  final String caption;
  final String imageHiddenSmXsMd;
  final String imageHiddenXlLg;

  BannerModel({
    required this.link,
    required this.caption,
    required this.imageHiddenSmXsMd,
    required this.imageHiddenXlLg,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      link: json['link'],
      caption: json['caption'],
      imageHiddenSmXsMd: json['image_hidden_sm_xs_md'],
      imageHiddenXlLg: json['image_hidden_xl_lg'],
    );
  }
}
