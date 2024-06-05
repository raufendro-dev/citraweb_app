// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:mikrotik/screens/lupa_password_screen.dart';
import 'package:mikrotik/screens/register_screen.dart';

import '../mixins/helper.dart';
import '../blocks/login_form_block.dart';
import '../providers/login_provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key})
      : usernameController = TextEditingController(),
        passwordController = TextEditingController(),
        super(key: key);

  final TextEditingController usernameController;
  final TextEditingController passwordController;

  // single approch way
  // final bloc = new FormBloc();

  @override
  Widget build(BuildContext context) {
    final FormBloc formBloc = LoginProvider.of(context);

    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 100.0, left: 50.0, right: 50.0),
          // height: 550.0,
          child: Form(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: Image.asset('assets/cst/splash.png'),
                ),
                _userIdField(formBloc),
                _passwordField(formBloc),
                SizedBox(
                  width: 300,
                  height: 35,
                  child: Helper().errorMessage(formBloc),
                ),
                _buttonField(formBloc),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                LupaPasswordScreen(),
                          )),
                      child: Container(
                        child: const Text('Lupa password?'),
                        alignment: Alignment.bottomLeft,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const RegisterScreen(),
                          )),
                      child: Container(
                        child: const Text('Register'),
                        alignment: Alignment.bottomLeft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userIdField(FormBloc bloc) {
    return StreamBuilder<String>(
        stream: bloc.userid,
        builder: (context, snapshot) {
          return TextField(
            controller: usernameController,
            decoration: InputDecoration(
              hintText: '',
              labelText: 'Username',
              errorText: snapshot.error?.toString(),
            ),
            onChanged: bloc.changeUserId,
          );
        });
  }

  Widget _passwordField(FormBloc bloc) {
    return StreamBuilder<String>(
        stream: bloc.password,
        builder: (context, snapshot) {
          return TextField(
            controller: passwordController,
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
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 20,
            ),
            child: ElevatedButton(
              onPressed: () {
                print('x');
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return;
                }
                if (usernameController.value.text.isEmpty ||
                    passwordController.value.text.isEmpty) {
                  print('username password kosong');
                  return;
                }
                bloc.login(context);
              },
              clipBehavior: Clip.hardEdge,
              child: const Text('Masuk'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.primary,
                elevation: 4,
              ),
            ),
          );
        });
  }
}
