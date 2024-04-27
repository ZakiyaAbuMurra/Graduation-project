import 'package:flutter/material.dart';
import 'package:recyclear/views/widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = MediaQuery.of(context).size.width < 600; // Example breakpoint for mobile

    return Scaffold(
      // extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            // padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //  SizedBox(height: size.height * 0.1),
                Container(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/login.png',
                    fit: BoxFit.fitWidth, // Change this depending on your image
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'Login to your account',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontWeight: FontWeight.bold,
                        //  color: AppColors.bla,
                      ),
                ),
                SizedBox(height: size.height * 0.01),
                const LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
