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
    return context.dependOnInheritedWidgetOfExactType<LoginProvider>()!.bloc;
  }
}
