import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mikrotik/constant/custom_icons.dart';

class DaftarTrainingSukses extends StatelessWidget {
  const DaftarTrainingSukses({Key? key, required this.msg}) : super(key: key);
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Pendaftaran Training Berhasil'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CustomIcons.training,
            color: Theme.of(context).colorScheme.primary,
            size: 100,
          ),
          Html(
            data: msg,
            style: {"*": Style(textAlign: TextAlign.center)},
          ),
        ],
      ),
    );
  }
}
