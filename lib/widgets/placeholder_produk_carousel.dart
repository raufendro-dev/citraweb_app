import 'package:flutter/material.dart';
import '../widgets/shimmer_widget.dart';

class PlaceholderProdukCarousel extends StatelessWidget {
  const PlaceholderProdukCarousel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 12,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ShimmerWidget.rectangular(
                    height: 18, width: MediaQuery.of(context).size.width * 0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ShimmerWidget.rectangular(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.75),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: ShimmerWidget.rectangular(height: 12),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: ShimmerWidget.rectangular(height: 12),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    SizedBox(
                      width: 150,
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Card(
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ShimmerWidget.rectangular(
                                  height: constraints.maxWidth * 1 - 6,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    bottom: 2, left: 6, right: 6),
                                child: ShimmerWidget.rectangular(height: 8),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    bottom: 12, left: 6, right: 6),
                                child: ShimmerWidget.rectangular(height: 8),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    bottom: 12, left: 6, right: 6),
                                child: ShimmerWidget.rectangular(
                                  height: 14,
                                  width: constraints.maxWidth * 0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
