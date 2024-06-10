import 'package:flutter/material.dart';

import '../blocks/login_form_block.dart';

class LoginProvider extends InheritedWidget {
  final bloc = FormBloc();
  // constructor, forward to Parent InheritedWidget
  LoginProvider({Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // Todo implantation
    return true;
  }

  static FormBloc of(BuildContext context) {
    // return (context.dependOnInheritedWidgetOfExactType<LoginProvider>() as LoginProvider).bloc;
    // return context.dependOnInheritedWidgetOfExactType<LoginProvider>()!.bloc;
    FormBloc? formBloc =
        context.dependOnInheritedWidgetOfExactType<LoginProvider>()?.bloc;
    if (formBloc != null) {
      print("tes hahaha");
      print(formBloc.toString());

      // Use formBloc here
      return formBloc;
    } else {
      throw Exception('LoginProvider not found in widget tree');
      // Handle the case where LoginProvider is not found
    }
  }
}
