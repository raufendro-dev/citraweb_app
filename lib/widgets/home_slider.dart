// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/banner_model.dart';
import '../widgets/custom_curved.dart';
import 'package:shimmer/shimmer.dart';

class HomeSilder extends StatefulWidget {
  const HomeSilder(
      {Key? key,
      required this.futureBanner,
      required CarouselController controller,
      this.indikator = false})
      : _controller = controller,
        super(key: key);

  final Future<List<BannerModel>> futureBanner;
  final CarouselController _controller;
  final bool indikator;

  @override
  State<HomeSilder> createState() => _HomeSilderState();
}

class _HomeSilderState extends State<HomeSilder> {
  int _current = 0;
  bool isEmpty = false;

  @override
  void initState() {
    super.initState();
    widget.futureBanner.then((value) {
      if (value.isEmpty) {
        setState(() {
          isEmpty = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build home slider');
    if (isEmpty) {
      print('kosong');
      return Container();
    }
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: widget.indikator ? 150 : 124,
          child: ClipPath(
            clipper: CustomCurved(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
              color: const Color.fromRGBO(77, 22, 131, 1),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          // width: MediaQuery.of(context).size.width,
          child: FutureBuilder<List<BannerModel>>(
            future: widget.futureBanner,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                if (snapshot.data!.isEmpty) {
                  return Container();
                }
                return Column(
                  children: [
                    CarouselSlider(
                      items: snapshot.data!
                          .map((e) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (await canLaunch(e.link)) {
                                        await launch(
                                          e.link,
                                        );
                                      } else {
                                        throw 'Could not launch ${e.link}';
                                      }
                                    },
                                    child: Image.network(
                                      e.imageHiddenSmXsMd,
                                      // fit: BoxFit.fitWidth,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                      carouselController: widget._controller,
                      options: CarouselOptions(
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 3.4,
                        viewportFraction: 1,
                        onPageChanged: widget.indikator
                            ? (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              }
                            : null,
                      ),
                    ),
                    if (widget.indikator)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: snapshot.data!.map((entry) {
                          return GestureDetector(
                            onTap: () => widget._controller
                                .animateToPage(snapshot.data!.indexOf(entry)),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // color: Colors.black,
                                color: (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(_current ==
                                            snapshot.data!.indexOf(entry)
                                        ? 0.9
                                        : 0.4),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                );
              }
              // else if (snapshot.hasError) {
              //   return Text('${snapshot.error}');
              // }

              // By default, show a loading spinner.
              // return const SizedBox(
              //   width: double.infinity,
              //   height: 100,
              //   child: Center(
              //       child: CircularProgressIndicator(strokeWidth: 2)),
              // );
              return Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[350]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(seconds: 2),
                    child: AspectRatio(
                      aspectRatio: 12.0 / 3.5,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[350]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(seconds: 2),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      width: 100,
                      height: 14,
                      color: Colors.white,
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
