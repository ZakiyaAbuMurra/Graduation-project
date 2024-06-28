import 'package:flutter/material.dart';
import 'package:recyclear/views/widgets/login_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: kIsWeb
          ? Center(
              child: Container(
                width: size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left side with logo and text
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        constraints: BoxConstraints(
                          maxWidth: 1000,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/greenRecyclear.png',
                              width: size.width *
                                  0.3, // Adjust this value as needed
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    // Right side with form
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Container(
                          width: 400,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Login to your account',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 20),
                              const LoginForm(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              width: double.infinity,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 600,
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
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
