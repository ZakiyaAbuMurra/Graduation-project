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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.05),
              Text(
                'Auth Page',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please, register!',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: AppColors.grey,
                    ),
              ),
              const SizedBox(height: 16),
              const RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}
