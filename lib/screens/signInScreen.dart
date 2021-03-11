import 'package:demo/controllers/auth_controller.dart';
import 'package:demo/exceptions/custom_exception.dart';

import 'package:demo/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthScreen extends HookWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('AuthScreen'),
      ),
      body: ProviderListener(
        onChange: (context, StateController<CustomException?> exception) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                duration: Duration(seconds: 3),
                content: Text(exception.state!.message!)),
          );
        },
        provider: loginExceptionProvider,
        child: Container(
          child: Column(
            children: [
              Text('AuthScreen'),
              TextField(
                controller: emailController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(hintText: 'email'),
                autofocus: true,
              ),
              TextField(
                controller: passwordController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(hintText: 'password'),
              ),
              ElevatedButton(
                onPressed: () => context
                    .read(authControllerProvider)
                    .signInWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    ),
                child: Text('SignIn'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends HookWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = useProvider(authControllerProvider.state);
    return authState == null ? AuthScreen() : HomePage();
  }
}
