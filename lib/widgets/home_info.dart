// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../widgets/shimmer_widget.dart';

class HomeInfo extends StatelessWidget {
  const HomeInfo({
    Key? key,
    required this.futureInfo,
  }) : super(key: key);

  final Future<List<String>> futureInfo;

  @override
  Widget build(BuildContext context) {
    print('build home info');
    return FutureBuilder<List<String>>(
      future: futureInfo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
              children: snapshot.data!
                  .map(
                    (e) => Container(
                      color: Colors.amber,
                      margin: const EdgeInsets.all(4),
                      child: Html(
                        data: e,
                        style: {
                          "h3": Style(
                            margin: const EdgeInsets.only(bottom: 0),
                            padding: const EdgeInsets.only(bottom: 0),
                            fontSize: FontSize.medium,
                          ),
                          "p": Style(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.only(bottom: 0),
                            fontSize: FontSize.small,
                          ),
                        },
                      ),
                    ),
                  )
                  .toList());
        }
        // else if (snapshot.hasError) {
        //   return Text('${snapshot.error}');
        // }

        // By default, show a loading spinner.
        // return const SizedBox(
        //   width: double.infinity,
        //   height: 100,
        //   child: Center(
        //       child: CircularProgressIndicator(
        //     strokeWidth: 2,
        //   )),
        // );

        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          width: double.infinity,
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ShimmerWidget.rectangular(
                      height: 18,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: ShimmerWidget.rectangular(height: 12),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: ShimmerWidget.rectangular(height: 12),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: ShimmerWidget.rectangular(height: 12),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ShimmerWidget.rectangular(
                      height: 18,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: ShimmerWidget.rectangular(height: 12),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: ShimmerWidget.rectangular(height: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
