import 'package:flutter/material.dart';
import '../blocks/login_form_block.dart';

class Helper {
  Widget errorMessage(FormBloc bloc) {
    return StreamBuilder<String>(
      stream: bloc.errorMessage,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data.toString(),
              style: const TextStyle(color: Colors.red));
        }
        return const Text('');
      },
    );
  }
}
