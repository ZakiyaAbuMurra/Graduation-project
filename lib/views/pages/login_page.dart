import 'package:flutter/material.dart';
import 'package:recyclear/views/widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600, // Set a max-width for web
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/login.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      'Login to your account',
                      style:
                          Theme.of(context).textTheme.headlineLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    const LoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
