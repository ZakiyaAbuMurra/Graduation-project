import 'package:flutter/material.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/views/widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // width: double.infinity,
                  child: Image.asset(
                    'assets/images/greenRecyclear.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                Text(
                  'Sign Up Page',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please, register!',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppColors.black.withOpacity(0.5),
                      ),
                ),
                const SizedBox(height: 16),
                const RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}