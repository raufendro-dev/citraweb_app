import 'package:flutter/material.dart';
import '../mixins/helper.dart';

import '../blocks/login_form_block.dart';
import '../providers/login_provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  // single approch way
  // final bloc = new FormBloc();

  @override
  Widget build(BuildContext context) {
    final FormBloc formBloc = LoginProvider.of(context);

    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 100.0, left: 50.0, right: 50.0),
          height: 550.0,
          child: Form(
            child: Column(
              children: <Widget>[
                _emailField(formBloc),
                _passwordField(formBloc),
                SizedBox(
                  width: 300,
                  height: 35,
                  child: Helper().errorMessage(formBloc),
                ),
                _buttonField(formBloc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField(FormBloc bloc) {
    return StreamBuilder<String>(
        stream: bloc.email,
        builder: (context, snapshot) {
          return TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'you@example.com',
              labelText: 'Email',
              errorText: snapshot.error?.toString(),
            ),
            onChanged: bloc.changeEmail,
          );
        });
  }

  Widget _passwordField(FormBloc bloc) {
    return StreamBuilder<String>(
        stream: bloc.password,
        builder: (context, snapshot) {
          return TextField(
            obscureText: true,
            onChanged: bloc.changePassword,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: '',
              labelText: 'Password',
              errorText: snapshot.error?.toString(),
            ),
          );
        });
  }

  Widget _buttonField(FormBloc bloc) {
    return StreamBuilder<bool>(
        stream: bloc.submitValidForm,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                if (snapshot.hasError) {
                  return;
                }
                bloc.register(context);
              },
              child: const Text('Daftar'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.primary,
                elevation: 4,
              ),
              clipBehavior: Clip.hardEdge,
            ),
          );
        });
  }
}
